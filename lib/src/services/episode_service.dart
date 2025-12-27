import '../network/api_client.dart';

class EpisodeService {
  final _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getEpisode(String id) async {
    final resp = await _dio.get('/episode/$id');
    if (resp.statusCode == 200) {
      return resp.data as Map<String, dynamic>;
    }
    throw Exception('Failed to load episode');
  }
}
