import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Configuracion especifica de la instancia de cache de acuerdo con las
// necesidades de la apliacion

class CustomImageCacheManager {
  static CacheManager instance = CacheManager(
    Config(
      'customImageCache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );
}
