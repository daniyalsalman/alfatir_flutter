import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alfatir_proj/theme/app_theme.dart';

class RagChatScreen extends StatefulWidget {
  const RagChatScreen({super.key});

  @override
  RagChatScreenState createState() => RagChatScreenState();
}

class RagChatScreenState extends State<RagChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  String? _sessionId;
  List<String> _sessions = [];
  bool _loading = false;

  // URL Config
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  @override
  void initState() {
    super.initState();
    _loadSessionList();
  }

  // ------------------ LOCAL STORAGE HELPERS ------------------
  
  // Save the list of messages for the current session to the phone
  Future<void> _persistChatLocally() async {
    if (_sessionId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String key = 'chat_history_$_sessionId';
    final String data = jsonEncode(_messages);
    await prefs.setString(key, data);
  }

  // Load messages from the phone immediately
  Future<void> _loadChatLocally(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'chat_history_$sessionId';
    final String? data = prefs.getString(key);
    
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        setState(() {
          _messages = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        });
        _scrollToBottom();
      } catch (e) {
        debugPrint("Error parsing local history: $e");
      }
    }
  }

  // ------------------ SESSION LIST MANAGEMENT ------------------
  Future<void> _loadSessionList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSessions = prefs.getStringList('rag_sessions') ?? [];
    
    // Auto-clean corrupted IDs
    final cleanSessions = savedSessions.where((id) => !id.contains('{')).toList();
    if (cleanSessions.length != savedSessions.length) {
      await prefs.setStringList('rag_sessions', cleanSessions);
    }

    if (mounted) {
      setState(() => _sessions = cleanSessions);
      if (_sessions.isNotEmpty) {
        _switchSession(_sessions.last);
      } else {
        _createNewSession();
      }
    }
  }

  Future<void> _saveSessionList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rag_sessions', _sessions);
  }

  Future<void> _removeSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('chat_history_$sessionId'); // Delete local messages
    
    setState(() {
      _sessions.remove(sessionId);
      if (_sessionId == sessionId) {
        _sessionId = null;
        _messages.clear();
      }
    });
    await _saveSessionList();
  }

  // ------------------ SERVER ACTIONS ------------------

  Future<void> _createNewSession() async {
    try {
      final resp = await http.post(Uri.parse('$baseUrl/session/new'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final newSessionId = data['session_id'].toString();

        setState(() {
          _sessionId = newSessionId;
          _sessions.add(newSessionId);
          _messages.clear();
        });
        await _saveSessionList();
        // New session is empty, no need to load history
      }
    } catch (e) {
      debugPrint('Error creating session: $e');
    }
  }

  Future<void> _switchSession(String sessionId) async {
    setState(() {
      _sessionId = sessionId;
      _messages.clear(); 
    });
    
    // 1. Load Local History FIRST (Instant UI)
    await _loadChatLocally(sessionId);
    
    // 2. Try to sync with Server in background
    await _syncWithServer(sessionId);
  }

  Future<void> _startNewChat() async {
    // Optional: Tell server to clear
    if (_sessionId != null) {
       try { await http.delete(Uri.parse('$baseUrl/session/clear/$_sessionId')); } catch (_) {}
       // Remove old session from list so we don't have duplicates
       await _removeSession(_sessionId!); 
    }
    await _createNewSession();
  }

  // ------------------ SERVER SYNC (SMART) ------------------
  Future<void> _syncWithServer(String sessionId) async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/history/$sessionId'));
      
      if (resp.statusCode == 200) {
        final body = resp.body.trim();
        List<Map<String, dynamic>> serverMessages = [];

        // Parse Server Response
        try {
          if (body.startsWith('{')) {
             final data = jsonDecode(body);
             dynamic rawList;
             if (data is Map && data.containsKey('history')) {
               rawList = data['history'];
               if (rawList is String && !rawList.trim().startsWith('[')) {
                 // "No conversation history yet." -> Server is empty
                 rawList = [];
               } else if (rawList is String) {
                 rawList = jsonDecode(rawList);
               }
             } else if (data is List) {
               rawList = data;
             }

             if (rawList is List) {
               for (var item in rawList) {
                 if (item is Map) {
                   serverMessages.add({
                     'user': (item['user'] ?? item['human'] ?? item['query'] ?? '').toString(),
                     'bot': (item['bot'] ?? item['ai'] ?? item['response'] ?? '').toString(),
                     'timestamp': item['timestamp']?.toString() ?? '',
                   });
                 } else if (item is List && item.length >= 2) {
                    serverMessages.add({
                     'user': item[0].toString(),
                     'bot': item[1].toString(),
                     'timestamp': '',
                   });
                 }
               }
             }
          }
        } catch (_) {}

        // LOGIC: Only overwrite local if server actually has data. 
        // If server says "Empty" but we have local messages, TRUST LOCAL (Server likely restarted).
        if (serverMessages.isNotEmpty) {
           if (mounted) {
             setState(() {
               _messages = serverMessages;
             });
             _persistChatLocally(); // Sync local with valid server data
           }
        } else {
          debugPrint("Server history empty. Keeping local history.");
        }
      } 
    } catch (e) {
      debugPrint("Sync failed: $e. Using local data.");
    }
  }

  // ------------------ SEND MESSAGE ------------------
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    if (_sessionId == null) await _createNewSession();
    
    final text = _controller.text.trim();
    _controller.clear();

    // 1. Update UI Immediately
    setState(() {
      _messages.add({
        'user': text,
        'bot': '', 
        'timestamp': DateTime.now().toIso8601String()
      });
      _loading = true;
    });
    _scrollToBottom();
    _persistChatLocally(); // Save "User Message" state

    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text, 'session_id': _sessionId}),
      );

      String botReply = "Error";
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        botReply = data['response']?.toString() ?? "No response";
      } else {
        botReply = "Server Error: ${resp.statusCode}";
      }

      if (mounted) {
        setState(() {
          _messages.last['bot'] = botReply;
          _loading = false;
        });
        _scrollToBottom();
        _persistChatLocally(); // Save "Bot Reply" state
      }
    } catch (e) {
      if (mounted) {
        setState(() {
           _messages.last['bot'] = "Connection Error. (Saved offline)";
           _loading = false;
        });
        _persistChatLocally();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ------------------ UI ------------------
  Widget _buildChatBubble(Map<String, dynamic> msg, bool isUser) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryGreen : (isDark ? const Color(0xFF333333) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12).copyWith(
             bottomRight: isUser ? Radius.zero : null,
             bottomLeft: !isUser ? Radius.zero : null,
          ),
        ),
        child: Text(
          isUser ? msg['user'] : msg['bot'],
          style: TextStyle(
            color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RAG Chatbot'),
          actions: [
             PopupMenuButton<String>(
               icon: const Icon(Icons.history, color: Colors.white),
               onSelected: _switchSession,
               itemBuilder: (_) => _sessions.map((s) => PopupMenuItem(
                 value: s,
                 child: Text("Session ${_sessions.indexOf(s) + 1}"),
               )).toList(),
             ),
             IconButton(
               icon: const Icon(Icons.add, color: Colors.white),
               onPressed: _startNewChat,
             ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _messages.isEmpty && !_loading
                  ? Center(child: Text("Ask a question to begin...", style: TextStyle(color: theme.hintColor)))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (ctx, i) {
                        final m = _messages[i];
                        return Column(
                          children: [
                            if (m['user'] != '') _buildChatBubble(m, true),
                            if (m['bot'] != '') _buildChatBubble(m, false),
                          ],
                        );
                      },
                    ),
            ),
            if (_loading) const LinearProgressIndicator(color: AppTheme.primaryGreen, minHeight: 2),
            Container(
              padding: const EdgeInsets.all(12),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(color: theme.hintColor),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      backgroundColor: AppTheme.primaryGreen,
                      onPressed: _loading ? null : _sendMessage,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}