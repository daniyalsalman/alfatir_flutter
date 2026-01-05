import 'package:flutter/material.dart';
import 'package:alfatir_proj/theme/app_theme.dart';
import 'app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check mode for conditional styling
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Fatir'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Dark mode uses a darker, sleeker gradient
              colors: isDark 
                  ? [Colors.black, const Color(0xFF0F553D)] 
                  : [AppTheme.darkGreen, AppTheme.primaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Container(
        // Dynamic Background (White in Light, Black/Grey in Dark)
        color: Theme.of(context).scaffoldBackgroundColor,
        child: GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildHomeCard(context, 'Quran', Icons.menu_book, AppRoutes.quran, Colors.teal),
            _buildHomeCard(context, 'Hadith', Icons.library_books, AppRoutes.hadith, Colors.brown),
            _buildHomeCard(context, 'Prayer Times', Icons.access_time_filled, AppRoutes.prayerTimes, Colors.orange),
            _buildHomeCard(context, 'Tasbeeh', Icons.fingerprint, AppRoutes.tasbeehCounter, Colors.purple),
            _buildHomeCard(context, 'Zakat Calc', Icons.calculate, '/zakat', Colors.green),
            _buildHomeCard(context, 'Qibla', Icons.explore, '/qibla', Colors.blueGrey),
            _buildHomeCard(context, '99 Names', Icons.stars, AppRoutes.namesOfAllah, AppTheme.accentGold),
            _buildHomeCard(context, 'Hijri', Icons.calendar_today, AppRoutes.hijriCalendar, Colors.indigo),
            _buildHomeCard(context, 'AI Chat', Icons.chat_bubble, AppRoutes.ragChat, Colors.blue),
            _buildHomeCard(context, 'Profile', Icons.person, AppRoutes.profile, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeCard(BuildContext context, String title, IconData icon, String route, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      // Card Color adapts automatically from AppTheme
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route).catchError((e) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon!')));
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              // Subtle gradient effect for depth
              colors: isDark 
                ? [AppTheme.darkCard, AppTheme.darkCard.withOpacity(0.8)] 
                : [Colors.white, color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Icon background is lighter in Dark Mode for contrast
                  color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  // Text color adapts automatically
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      // Drawer background adapts automatically
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [Colors.black, const Color(0xFF0F553D)] 
                    : [AppTheme.darkGreen, AppTheme.primaryGreen],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.mosque, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'Al-Fatir',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Your Daily Islamic Companion',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.home, 'Home', () => Navigator.pop(context)),
          _buildDrawerItem(context, Icons.settings, 'Settings', () { Navigator.pushNamed(context, AppRoutes.profile); }),
          const Divider(),
          _buildDrawerItem(context, Icons.logout, 'Logout', () {
             Navigator.pushNamedAndRemoveUntil(context, AppRoutes.initialAuth, (route) => false);
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: onTap,
    );
  }
}