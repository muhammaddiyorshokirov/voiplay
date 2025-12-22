import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppCacheManager {
  AppCacheManager._();

  static final CacheManager instance = CacheManager(
    Config(
      'voiplayCache',
      stalePeriod: const Duration(hours: 48),
      maxNrOfCacheObjects: 200,
    ),
  );
}
