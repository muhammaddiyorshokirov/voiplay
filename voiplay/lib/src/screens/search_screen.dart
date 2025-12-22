import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/app_cache_manager.dart';
import 'dart:developer' as developer;
import '../models/models.dart';
import '../services/api.dart';
import '../utils/constants.dart';
import 'anime_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Anime> searchResults = [];
  List<Anime> allAnime = [];
  bool isLoading = false;
  bool hasSearched = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadAllAnime();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      setState(() {
        searchResults = List<Anime>.from(allAnime);
        hasSearched = true;
      });
      return;
    }

    // Debounce to avoid excessive API calls
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      // Prefer local filtering for snappy UX
      _filterLocal(q);
    });
  }

  Future<void> _loadAllAnime() async {
    setState(() => isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final data = await api.getAnime(page: 1, perPage: 200);
      setState(() {
        allAnime = data
            .whereType<Map<String, dynamic>>()
            .map((e) => Anime.fromJson(e))
            .toList();
        searchResults = List<Anime>.from(allAnime);
        hasSearched = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        allAnime = [];
        searchResults = [];
        isLoading = false;
        hasSearched = true;
      });
    }
  }

  void _filterLocal(String q) {
    final lower = q.toLowerCase();
    final filtered =
        allAnime.where((a) => a.title.toLowerCase().contains(lower)).toList();
    setState(() {
      searchResults = filtered;
      hasSearched = true;
      isLoading = false;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults.clear();
        hasSearched = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final results = await api.search(query.trim());

      setState(() {
        if (results != null &&
            results['anime'] != null &&
            results['anime'] is List) {
          searchResults = (results['anime'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => Anime.fromJson(item))
              .toList();
        } else if (results != null && results is List) {
          // fallback if API returns a raw list
          searchResults = (results as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => Anime.fromJson(item))
              .toList();
        } else {
          searchResults = [];
        }
        isLoading = false;
      });
    } catch (e) {
      developer.log('Search error: $e');
      setState(() {
        searchResults = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Qidirish', style: AppStyles.headlineM),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppDimens.paddingL),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: AppStyles.bodyM,
              decoration: InputDecoration(
                hintText: 'Animeni qidirish...',
                hintStyle: AppStyles.labelL.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchResults.clear();
                            hasSearched = false;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: !hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search,
                          size: AppDimens.iconXL,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppDimens.paddingL),
                        Text(
                          'Animeni qidirish uchun\nso\'z kiriting',
                          style: AppStyles.bodyM.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      )
                    : searchResults.isEmpty
                        ? Center(
                            child: Text(
                              'Natija topilmadi',
                              style: AppStyles.bodyM.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(AppDimens.paddingL),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: AppDimens.paddingM,
                              mainAxisSpacing: AppDimens.paddingL,
                            ),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              return _buildSearchResultCard(
                                  searchResults[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Anime anime) {
    final tag = 'anime-cover-${anime.id}-search';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AnimeDetailScreen(animeId: anime.id, heroTag: tag),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          color: AppColors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimens.radiusL),
                      ),
                      child: Hero(
                        tag: tag,
                        child: CachedNetworkImage(
                          cacheManager: AppCacheManager.instance,
                          imageUrl: anime.image ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const ColoredBox(color: AppColors.surface),
                          errorWidget: (context, url, error) =>
                              const ColoredBox(color: AppColors.surface),
                        ),
                      ),
                    ),
                  ),
                  if (anime.isPremium)
                    Positioned(
                      top: AppDimens.paddingM,
                      right: AppDimens.paddingM,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingS,
                          vertical: AppDimens.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusS,
                          ),
                        ),
                        child: Text(
                          'Premium',
                          style: AppStyles.labelM.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.titleM,
                  ),
                  const SizedBox(height: AppDimens.paddingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${anime.rating} ⭐',
                        style: AppStyles.labelM.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      Text('${anime.releaseYear}', style: AppStyles.labelM),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
