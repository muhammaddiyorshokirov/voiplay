import '../network/api_client.dart';

class FavoriteService {
  final _dio = ApiClient().dio;

  Future<void> addFavorite(String animeId) async {
    await _dio.post('/favorites', data: {'anime_id': animeId});
  }

  Future<void> removeFavorite(String id) async {
    await _dio.delete('/favorites/$id');
  }

  Future<List<dynamic>> getFavorites() async {
    final resp = await _dio.get('/favorites');
    if (resp.statusCode == 200) return resp.data as List<dynamic>;
    return [];
  }
}
