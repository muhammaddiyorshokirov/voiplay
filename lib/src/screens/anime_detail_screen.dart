import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/app_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
import '../services/auth_service.dart';
import 'watch_screen.dart';

class AnimeDetailScreen extends StatefulWidget {
  final String animeId;
  final String? heroTag;
  const AnimeDetailScreen({super.key, required this.animeId, this.heroTag});

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  late ApiService api;
  Map<String, dynamic>? anime;
  List<dynamic> episodes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    api = Provider.of<ApiService>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final a = await api.getAnimeById(widget.animeId);
      final e = await api.getEpisodesByAnime(widget.animeId);
      setState(() {
        anime = a;
        episodes = e;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isFavorite = auth.isFavorite(widget.animeId);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.black87],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.black87,
              expandedHeight: 300,
              flexibleSpace: loading || anime == null
                  ? FlexibleSpaceBar(
                      title: const Text('Yuklanmoqda...'),
                      background: Container(color: Colors.grey.shade700),
                    )
                  : FlexibleSpaceBar(
                      title: Text(
                        anime!['title'] ?? 'Noma\'lum',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: widget.heroTag ??
                                'anime-cover-${widget.animeId}',
                            child: CachedNetworkImage(
                              cacheManager: AppCacheManager.instance,
                              imageUrl: anime!['cover_image'] ??
                                  anime!['image'] ??
                                  '',
                              fit: BoxFit.cover,
                              placeholder: (c, u) =>
                                  Container(color: Colors.grey.shade700),
                              errorWidget: (c, u, e) =>
                                  Container(color: Colors.grey.shade700),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.red.shade400,
                  ),
                  onPressed: () async {
                    if (isFavorite) {
                      auth.removeFromFavorites(widget.animeId);
                      // also remove from local saved list for offline view
                      final prefs = await SharedPreferences.getInstance();
                      final saved = prefs.getStringList('saved_animes') ?? [];
                      saved.remove(widget.animeId);
                      await prefs.setStringList('saved_animes', saved);
                    } else {
                      auth.addToFavorites(widget.animeId);
                      // also add to local saved list for offline view
                      final prefs = await SharedPreferences.getInstance();
                      final saved = prefs.getStringList('saved_animes') ?? [];
                      if (!saved.contains(widget.animeId)) {
                        saved.add(widget.animeId);
                        await prefs.setStringList('saved_animes', saved);
                      }
                    }
                  },
                ),
              ],
            ),
            if (loading)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.red.shade400),
                  ),
                ),
              )
            else if (anime != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${(anime!['rating'] ?? 0).toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${anime!['release_year'] ?? '?'}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (anime!['is_premium'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Premium',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (anime!['description'] != null &&
                          anime!['description'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tasnifi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              anime!['description'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Episodelar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (episodes.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Episodelar topilmadi',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ...episodes.map((episode) {
                          final isPremium = episode['is_premium'] == true;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: isPremium && !auth.premium
                                  ? null
                                  : () {
                                      // add episode to watch history (last 20)
                                      auth.addToHistory(
                                        episode['id'].toString(),
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => WatchScreen(
                                            episodeId: episode['id'],
                                            animeTitle: anime!['title'],
                                          ),
                                        ),
                                      );
                                    },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (isPremium && !auth.premium)
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.workspace_premium,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      )
                                    else
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          cacheManager:
                                              AppCacheManager.instance,
                                          imageUrl: episode['thumbnail'] ?? '',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey.shade700,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey.shade700,
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.white30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'E${episode['episode_number'] ?? '?'}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  episode['title'] ??
                                                      'Noma\'lum',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${episode['duration'] ?? 0} daqiqa',
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      (isPremium && !auth.premium)
                                          ? Icons.lock
                                          : Icons.play_arrow,
                                      color: (isPremium && !auth.premium)
                                          ? Colors.amber
                                          : Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
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
