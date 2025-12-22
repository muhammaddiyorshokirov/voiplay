import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'anime_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Map<String, dynamic>> savedAnimes = [];
  bool isLoading = true;
  late ApiService api;

  @override
  void initState() {
    super.initState();
    api = Provider.of<ApiService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    // reload saved animes when auth favorites change
    auth.addListener(_loadSavedAnimes);
    _loadSavedAnimes();
  }

  Future<void> _loadSavedAnimes() async {
    try {
      // if logged in, prefer server-side favorites stored in AuthService
      final auth = Provider.of<AuthService>(context, listen: false);
      final animes = <Map<String, dynamic>>[];

      final ids = auth.isLoggedIn
          ? auth.favorites
          : (await SharedPreferences.getInstance()).getStringList(
                'saved_animes',
              ) ??
              [];

      if (ids.isEmpty) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      for (final id in ids) {
        try {
          final animeData = await api.getAnimeById(id);
          if (animeData != null) animes.add(animeData);
        } catch (e) {
          debugPrint('Error loading anime: $e');
        }
      }

      if (mounted) {
        setState(() {
          savedAnimes = animes;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _removeSavedAnime(String animeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList('saved_animes') ?? [];
      savedIds.remove(animeId);
      await prefs.setStringList('saved_animes', savedIds);

      setState(() {
        savedAnimes.removeWhere((anime) => anime['id'] == animeId);
      });
    } catch (e) {
      debugPrint('Error removing saved: $e');
    }
  }

  @override
  void dispose() {
    final auth = Provider.of<AuthService>(context, listen: false);
    auth.removeListener(_loadSavedAnimes);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Saqlangan', style: AppStyles.headlineM),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            )
          : savedAnimes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bookmark_outline,
                        size: AppDimens.iconXL,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppDimens.paddingL),
                      Text(
                        'Saqlangan animelar yo\'q',
                        style: AppStyles.titleL.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppDimens.paddingL),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: AppDimens.paddingM,
                    mainAxisSpacing: AppDimens.paddingL,
                  ),
                  itemCount: savedAnimes.length,
                  itemBuilder: (context, index) {
                    return _buildSavedAnimeCard(savedAnimes[index]);
                  },
                ),
    );
  }

  Widget _buildSavedAnimeCard(Map<String, dynamic> anime) {
    final animeId = anime['id']?.toString() ?? '';
    final title = anime['title']?.toString() ?? '';
    final image = anime['image']?.toString() ?? '';
    final rating = anime['rating']?.toString() ?? '0';
    final releaseYear = anime['releaseYear']?.toString() ?? '';
    final isPremium = anime['isPremium'] == true;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimeDetailScreen(animeId: animeId),
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimens.radiusL),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const ColoredBox(color: AppColors.surface),
                      errorWidget: (context, url, error) =>
                          const ColoredBox(color: AppColors.surface),
                    ),
                  ),
                  Positioned(
                    top: AppDimens.paddingM,
                    right: AppDimens.paddingM,
                    child: GestureDetector(
                      onTap: () {
                        _removeSavedAnime(animeId);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppDimens.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusS,
                          ),
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          color: AppColors.text,
                          size: AppDimens.iconM,
                        ),
                      ),
                    ),
                  ),
                  if (isPremium)
                    Positioned(
                      bottom: AppDimens.paddingM,
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
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.titleM,
                  ),
                  const SizedBox(height: AppDimens.paddingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$rating ⭐',
                        style: AppStyles.labelM.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(releaseYear, style: AppStyles.labelM),
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
}
