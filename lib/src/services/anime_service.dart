import '../network/api_client.dart';

class AnimeService {
  final _dio = ApiClient().dio;

  Future<List<dynamic>> fetchAnimes({int page = 1, int limit = 20}) async {
    final resp = await _dio.get(
      '/anime',
      queryParameters: {'page': page, 'limit': limit},
    );
    if (resp.statusCode == 200) {
      return resp.data as List<dynamic>;
    }
    throw Exception('Failed to load anime list');
  }

  Future<Map<String, dynamic>> getAnime(String id) async {
    final resp = await _dio.get('/anime/$id');
    if (resp.statusCode == 200) {
      return resp.data as Map<String, dynamic>;
    }
    throw Exception('Failed to load anime detail');
  }
}
