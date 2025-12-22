import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api.dart';
import '../services/app_cache_manager.dart';
import '../utils/constants.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId;
  final String heroTag;
  const NewsDetailScreen({
    required this.newsId,
    required this.heroTag,
    super.key,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  Map<String, dynamic>? _news;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final res = await api.getNewsById(widget.newsId);
      if (!mounted) return;
      setState(() => _news = res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yangilikni ochishda xato: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _share() {
    final title = _news?['title'] ?? '';
    final url = 'https://link.voiplay/news/${widget.newsId}';
    Share.share('$title\n$url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yangilik'),
        actions: [
          IconButton(
            onPressed: _news == null ? null : _share,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _news == null
              ? Center(
                  child: Text('Yangilik topilmadi', style: AppStyles.bodyM),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((_news?['image'] ?? '').toString().isNotEmpty)
                        Hero(
                          tag: widget.heroTag,
                          child: CachedNetworkImage(
                            cacheManager: AppCacheManager.instance,
                            imageUrl: _news?['image'] ?? '',
                            width: double.infinity,
                            height: 260,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => Container(
                              color: Colors.grey.shade800,
                              height: 260,
                            ),
                            errorWidget: (c, u, e) => Container(
                              color: Colors.grey.shade800,
                              height: 260,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 260,
                          color: Colors.grey.shade800,
                          child: const Center(
                            child: Icon(
                              Icons.article,
                              size: 64,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(AppDimens.paddingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _news?['title'] ?? 'Sarlavha yo‘q',
                              style: AppStyles.headlineM,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if ((_news?['author_name'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                  Text(
                                    _news?['author_name'] ?? '',
                                    style: AppStyles.labelM,
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  (_news?['published_at'] ?? '')
                                      .toString()
                                      .split('T')
                                      .first,
                                  style: AppStyles.labelM.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimens.paddingM),
                            Text(
                              (_news?['content'] ?? '')
                                  .toString()
                                  .replaceAll(RegExp(r'<[^>]*>'), '\n')
                                  .trim(),
                              style: AppStyles.bodyM.copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
