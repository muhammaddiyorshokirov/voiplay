import 'package:flutter/material.dart';
import '../services/anime_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // Attempt to get current user info (if /users/me exists)
      await AnimeService().fetchAnimes(
        page: 1,
        limit: 1,
      ); // placeholder to ensure api works
      // For now, show a simple profile placeholder
      setState(() => _user = {'name': 'User', 'email': 'user@example.com'});
    } catch (_) {
      setState(() => _user = {'name': 'User', 'email': 'user@example.com'});
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${_user?['name'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Email: ${_user?['email'] ?? ''}'),
        ],
      ),
    );
  }
}
