import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';
import '../services/app_cache_manager.dart';
import '../utils/constants.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  final List<dynamic> _items = [];
  final Set<String> _ids = {};

  final ScrollController _ctrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _ctrl.addListener(() {
      if (_ctrl.position.pixels >= _ctrl.position.maxScrollExtent - 200 &&
          !_loading &&
          _hasMore) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _page = 1;
    _hasMore = true;
    _items.clear();
    _ids.clear();
    setState(() {});
    await _load();
  }

  Future<void> _load() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final data = await api.getNews(page: _page, perPage: 10);
      if (!mounted) return;
      setState(() {
        if (data.isEmpty) {
          _hasMore = false;
        } else {
          final newItems = <dynamic>[];
          for (final it in data) {
            final id = (it['id'] ?? it['news_id'] ?? it['slug'])?.toString();
            if (id == null) continue;
            if (!_ids.contains(id)) {
              _ids.add(id);
              newItems.add(it);
            }
          }
          if (newItems.isEmpty) {
            _hasMore = false;
          } else {
            _items.addAll(newItems);
            _page++;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yangiliklarni yuklashda xato: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yangiliklar'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _items.isEmpty && _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _ctrl,
                padding: const EdgeInsets.all(AppDimens.paddingM),
                itemCount: _items.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _items.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: _loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _load,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                ),
                                child: const Text('Yana yuklash'),
                              ),
                      ),
                    );
                  }

                  final item = _items[index];
                  final image =
                      (item['image'] ?? item['cover'] ?? '') as String;
                  final excerpt =
                      (item['excerpt'] ?? item['summary'] ?? '') as String;
                  final date = (item['published_at'] ??
                      item['created_at'] ??
                      '') as String;
                  final tag = 'news-${item['id']}-$index';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewsDetailScreen(
                            newsId: item['id'].toString(),
                            heroTag: tag,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: AppDimens.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusL,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(102, 0, 0, 0),
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (image.isNotEmpty)
                            Hero(
                              tag: tag,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: CachedNetworkImage(
                                  cacheManager: AppCacheManager.instance,
                                  imageUrl: image,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  placeholder: (c, u) => Container(
                                    color: Colors.grey.shade800,
                                    height: 180,
                                  ),
                                  errorWidget: (c, u, e) => Container(
                                    color: Colors.grey.shade800,
                                    height: 180,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.article,
                                  size: 48,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(AppDimens.paddingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? 'Sarlavha yo‘q',
                                  style: AppStyles.titleL.copyWith(
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  excerpt.isNotEmpty
                                      ? excerpt
                                      : (item['content'] ?? '')
                                          .toString()
                                          .replaceAll(
                                            RegExp(r'<[^>]*>|\\s+'),
                                            ' ',
                                          )
                                          .trim(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.bodyM.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      date.isNotEmpty
                                          ? date.split('T').first
                                          : '',
                                      style: AppStyles.labelM,
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
