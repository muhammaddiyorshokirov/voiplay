import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/anime_service.dart';
import '../services/favorite_service.dart';
import 'episode_watch_screen.dart';
import '_comments_widget.dart';

class AnimeDetailScreen extends StatefulWidget {
  final String animeId;
  const AnimeDetailScreen({super.key, required this.animeId});

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  final _service = AnimeService();
  final _favService = FavoriteService();
  Map<String, dynamic>? _anime;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getAnime(widget.animeId);
      setState(() => _anime = data);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFav() async {
    try {
      await _favService.addFavorite(widget.animeId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sevimlilarga qo\'shildi')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_anime == null) {
      return const Scaffold(body: Center(child: Text('Topilmadi')));
    }

    final title = _anime!['title'] ?? _anime!['name'] ?? 'Nomi yo‘q';
    final poster = _anime!['poster'] ?? _anime!['image'];
    final description = _anime!['description'] ?? '';
    final episodes = _anime!['episodes'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _toggleFav,
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (poster != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: poster,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            const Text(
              'Epizodlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...episodes.map((e) {
              final m = e as Map<String, dynamic>;
              final epTitle = m['title'] ?? 'Epizod';
              return ListTile(
                title: Text(epTitle),
                trailing: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EpisodeWatchScreen(episodeId: m['id'].toString()),
                    ),
                  ),
                  child: const Text('Ko\'rish'),
                ),
              );
            }),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Izohlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CommentsWidget(animeId: widget.animeId),
          ],
        ),
      ),
    );
  }
}
