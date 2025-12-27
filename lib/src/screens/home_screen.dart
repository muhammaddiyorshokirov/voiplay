import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'anime_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    AnimeListScreen(),
    Center(child: Text('Qidiruv - tez orada')),
  ];

  Future<void> _openPremium() async {
    final uri = Uri.parse('https://t.me/voiplay_price/3');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // ignore: avoid_print
      print('Could not open $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiPlay Tv'),
        actions: [
          IconButton(onPressed: _openPremium, icon: const Icon(Icons.star)),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bosh sahifa'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Qidiruv'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Sevimlilar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
