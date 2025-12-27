import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/anime_service.dart';
import 'anime_detail_screen.dart';

class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});

  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  final _service = AnimeService();
  List<dynamic> _animes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchAnimes();
      setState(() => _animes = data);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_animes.isEmpty && !_loading) {
      return const Center(child: Text('Hozircha anime topilmadi'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _animes.length,
        itemBuilder: (context, i) {
          final a = _animes[i] as Map<String, dynamic>;
          final title = a['title'] ?? a['name'] ?? 'Untitled';
          final poster = a['poster'] ?? a['image'];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnimeDetailScreen(animeId: a['id'].toString()),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: poster != null
                        ? CachedNetworkImage(
                            imageUrl: poster,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey[300]),
                  ),
                ),
                const SizedBox(height: 8),
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }
}
