import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // final String baseUrl = 'http://localhost:8000';
  final String baseUrl = 'http://192.168.0.102:8000';


  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // ------------------ SharedPreferences helpers ------------------
  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rag_sessions', _sessions);
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSessions = prefs.getStringList('rag_sessions');
    if (savedSessions != null && savedSessions.isNotEmpty) {
      _sessions = savedSessions;
      _sessionId = _sessions.last;
      _loadHistory();
    } else {
      _createNewSession();
    }
  }

  Future<void> _removeSession(String sessionId) async {
    _sessions.remove(sessionId);
    await _saveSessions();
  }

  // ------------------ SESSION MANAGEMENT ------------------
  Future<void> _createNewSession() async {
    try {
      final resp = await http.post(Uri.parse('$baseUrl/session/new'));
      if (resp.statusCode == 200) {
        final newSessionId = resp.body.replaceAll('"', '').trim();
        _sessionId = newSessionId;
        _sessions.add(newSessionId);
        await _saveSessions();
        setState(() {
          _messages.clear();
        });
        _loadHistory();
      }
    } catch (e) {
      debugPrint('Error creating session: $e');
    }
  }

  Future<void> _switchSession(String sessionId) async {
    _sessionId = sessionId;
    _loadHistory();
  }

  Future<void> _startNewChat() async {
    if (_sessionId == null) return;

    try {
      await http.post(Uri.parse('$baseUrl/session/clear/$_sessionId'));
    } catch (_) {}

    await _removeSession(_sessionId!);

    setState(() {
      _messages.clear();
      _sessionId = null;
    });

    _createNewSession();
  }

  // ------------------ HISTORY ------------------
  Future<void> _loadHistory() async {
    if (_sessionId == null) return;
    try {
      final resp = await http.get(Uri.parse('$baseUrl/history/$_sessionId'));
      if (resp.statusCode == 200) {
        final body = resp.body.trim();

        // Handle raw text (You: ..., AI: ...)
        List<Map<String, dynamic>> loadedMessages = [];
        if (body.startsWith('{')) {
          // If backend sends JSON, parse normally
          final data = jsonDecode(body);
          if (data.containsKey('history')) {
            final historyString = data['history'] as String;
            final List<dynamic> historyList = jsonDecode(historyString);
            loadedMessages = historyList.map((e) {
              return {
                'user': e['user'],
                'bot': e['bot'],
                'timestamp': e['timestamp'] ?? DateTime.now().toIso8601String(),
              };
            }).toList();
          }
        } else {
          // Plain text parsing
          final lines = body.split('\n');
          for (var line in lines) {
            if (line.startsWith('You: ')) {
              loadedMessages.add({
                'user': line.substring(5),
                'bot': '',
                'timestamp': DateTime.now().toIso8601String()
              });
            } else if (line.startsWith('AI: ')) {
              loadedMessages.add({
                'user': '',
                'bot': line.substring(4),
                'timestamp': DateTime.now().toIso8601String()
              });
            }
          }
        }

        setState(() {
          _messages = loadedMessages;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  // ------------------ SEND MESSAGE ------------------
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _sessionId == null) return;

    final userMessage = _controller.text.trim();
    setState(() {
      _messages.add({
        'user': userMessage,
        'bot': '',
        'timestamp': DateTime.now().toIso8601String()
      });
      _controller.clear();
      _loading = true;
    });
    _scrollToBottom();

    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage, 'session_id': _sessionId}),
      );

      String botResponse = '';
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is Map && data.containsKey('response')) {
          botResponse = data['response']?.toString().trim() ?? '';
        } else {
          botResponse = resp.body.replaceAll('"', '').trim();
        }
      } else {
        botResponse = 'Error: Failed to get response';
      }

      setState(() {
        _messages.last['bot'] = botResponse;
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
      setState(() => _loading = false);
    }
  }

  // ------------------ SCROLL ------------------
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ------------------ CHAT BUBBLES ------------------
  Widget _buildChatBubble(Map<String, dynamic> message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? message['user'] : message['bot'],
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['timestamp'].toString().substring(0, 16),
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ BUILD ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RAG Chatbot'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _switchSession,
            itemBuilder: (context) => _sessions
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Text('Session ${_sessions.indexOf(s) + 1}'),
                    ))
                .toList(),
            icon: const Icon(Icons.switch_account),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewChat,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Column(
                  children: [
                    if (msg['user'].isNotEmpty) _buildChatBubble(msg, true),
                    if (msg['bot'].isNotEmpty) _buildChatBubble(msg, false),
                  ],
                );
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                _loading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
