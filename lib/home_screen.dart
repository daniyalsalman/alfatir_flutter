import 'package:flutter/material.dart';
import 'app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Hadith'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.hadith);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Quran'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.quran);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Prayer Times'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.prayerTimes);
              },
            ),
            ListTile(
              leading: const Icon(Icons.countertops),
              title: const Text('Tasbeeh Counter'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.tasbeehCounter);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
             ListTile(
              leading: const Icon(Icons.person),
              title: const Text('RAG Chatbot'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.ragChat);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.hadith);
              },
              child: const Text('Hadith'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.quran);
              },
              child: const Text('Quran'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.prayerTimes);
              },
              child: const Text('Prayer Times'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.tasbeehCounter);
              },
              child: const Text('Tasbeeh Counter'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.ragChat);
              },
              child: const Text('RAG Chatbot'),
            ),
          ],
        ),
      ),
    );
  }
}