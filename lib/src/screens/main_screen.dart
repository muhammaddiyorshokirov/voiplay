import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'home_screen.dart';
import 'anime_list_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'news_list_screen.dart';
import '../widgets/offline_prompt.dart';
import 'offline_screen.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const AnimeListScreen(),
    const SavedScreen(),
    const NewsListScreen(),
    const ProfileScreen(),
  ];

  bool _connectivityChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConnectivity());
  }

  void _openOfflineScreen() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OfflineScreen()),
    );
  }

  Future<void> _checkConnectivity() async {
    if (_connectivityChecked) return;
    _connectivityChecked = true;
    try {
      final dynamic conn = await Connectivity().checkConnectivity();
      if (!mounted) return;
      if (conn is ConnectivityResult) {
        if (conn == ConnectivityResult.none) {
          showOfflinePrompt(context, onGo: _openOfflineScreen);
          return;
        }
      } else if (conn is List && conn.contains(ConnectivityResult.none)) {
        showOfflinePrompt(context, onGo: _openOfflineScreen);
        return;
      }
      final api = Provider.of<ApiService>(context, listen: false);
      try {
        final ok = await api.ping();
        if (!mounted) return;
        if (!ok) {
          showOfflinePrompt(context, onGo: _openOfflineScreen);
        }
      } catch (e) {
        if (!mounted) return;
        showOfflinePrompt(context, onGo: _openOfflineScreen);
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.red.shade400,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Asosiy'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Animelar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saqlangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Yangiliklar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
