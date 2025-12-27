import '../network/api_client.dart';

class CommentService {
  final _dio = ApiClient().dio;

  Future<List<dynamic>> fetchComments({
    String? animeId,
    String? episodeId,
  }) async {
    final resp = await _dio.get(
      '/comments',
      queryParameters: {
        if (animeId != null) 'anime_id': animeId,
        if (episodeId != null) 'episode_id': episodeId,
      },
    );
    if (resp.statusCode == 200) return resp.data as List<dynamic>;
    return [];
  }

  Future<void> postComment({
    String? animeId,
    String? episodeId,
    required String text,
  }) async {
    final data = {
      if (animeId != null) 'anime_id': animeId,
      if (episodeId != null) 'episode_id': episodeId,
      'comment_text': text,
    };
    await _dio.post('/comments', data: data);
  }
}
