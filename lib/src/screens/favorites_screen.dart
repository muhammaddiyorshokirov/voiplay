import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/favorite_service.dart';
import 'anime_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = FavoriteService();
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await _service.getFavorites();
      setState(() => _items = d);
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('No favorites yet'));

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i] as Map<String, dynamic>;
        return ListTile(
          leading: item['poster'] != null
              ? CachedNetworkImage(
                  imageUrl: item['poster'],
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                )
              : null,
          title: Text(item['title'] ?? 'Untitled'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnimeDetailScreen(
                animeId: item['anime_id']?.toString() ?? item['id'].toString(),
              ),
            ),
          ),
        );
      },
    );
  }
}
