import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = 'https://api.voiplay.uz/api/v3';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;

  void setAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> loadTokensFromStorage() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
  }

  Future<void> clearAuthTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Map<String, String> _defaultHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<http.Response> _httpGet(Uri uri) async {
    return await http
        .get(uri, headers: _defaultHeaders())
        .timeout(const Duration(seconds: 8));
  }

  Future<http.Response> _httpPost(Uri uri, String body) async {
    return await http
        .post(uri, headers: _defaultHeaders(), body: body)
        .timeout(const Duration(seconds: 8));
  }

  Future<http.Response> _httpPut(Uri uri, String body) async {
    return await http
        .put(uri, headers: _defaultHeaders(), body: body)
        .timeout(const Duration(seconds: 8));
  }

  Future<http.Response> _httpDelete(Uri uri) async {
    return await http
        .delete(uri, headers: _defaultHeaders())
        .timeout(const Duration(seconds: 8));
  }

  Future<Map<String, dynamic>?> _tryParseResponse(http.Response res) async {
    if (res.statusCode == 200 || res.statusCode == 201) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 401 && _refreshToken != null) {
      final refreshed = await refresh(_refreshToken!);
      if (refreshed != null &&
          refreshed['access_token'] != null &&
          refreshed['refresh_token'] != null) {
        setAuthTokens(
          accessToken: refreshed['access_token'],
          refreshToken: refreshed['refresh_token'],
        );
        return null; // Caller should retry after refresh
      }
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  Future<Map<String, dynamic>?> get(
    String path, [
    Map<String, String>? params,
  ]) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: params);
    try {
      final res = await _httpGet(uri);
      final parsed = await _tryParseResponse(res);
      if (parsed == null) {
        final retry = await _httpGet(uri);
        return json.decode(retry.body) as Map<String, dynamic>;
      }
      return parsed;
    } catch (e) {
      if (kIsWeb &&
          (e.toString().contains('XMLHttpRequest') ||
              e.toString().contains('CORS') ||
              e.toString().contains('Cross'))) {
        throw Exception('Web network error (possible CORS): $e');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await _httpPost(uri, json.encode(body));
      final parsed = await _tryParseResponse(res);
      if (parsed == null) {
        final retry = await _httpPost(uri, json.encode(body));
        return json.decode(retry.body) as Map<String, dynamic>;
      }
      return parsed;
    } catch (e) {
      if (kIsWeb &&
          (e.toString().contains('XMLHttpRequest') ||
              e.toString().contains('CORS') ||
              e.toString().contains('Cross'))) {
        throw Exception('Web network error (possible CORS): $e');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await _httpPut(uri, json.encode(body));
      final parsed = await _tryParseResponse(res);
      if (parsed == null) {
        final retry = await _httpPut(uri, json.encode(body));
        return json.decode(retry.body) as Map<String, dynamic>;
      }
      return parsed;
    } catch (e) {
      if (kIsWeb &&
          (e.toString().contains('XMLHttpRequest') ||
              e.toString().contains('CORS') ||
              e.toString().contains('Cross'))) {
        throw Exception('Web network error (possible CORS): $e');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<bool> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await _httpDelete(uri);
      if (res.statusCode == 200) return true;
      if (res.statusCode == 401 && _refreshToken != null) {
        final refreshed = await refresh(_refreshToken!);
        if (refreshed != null &&
            refreshed['access_token'] != null &&
            refreshed['refresh_token'] != null) {
          setAuthTokens(
            accessToken: refreshed['access_token'],
            refreshToken: refreshed['refresh_token'],
          );
          final retry = await _httpDelete(uri);
          return retry.statusCode == 200;
        }
      }
      return false;
    } catch (e) {
      if (kIsWeb &&
          (e.toString().contains('XMLHttpRequest') ||
              e.toString().contains('CORS') ||
              e.toString().contains('Cross'))) {
        throw Exception('Web network error (possible CORS): $e');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    return await post('/auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>?> refresh(String refreshToken) async {
    final res = await post('/auth/refresh', {'refresh_token': refreshToken});
    return res;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    return await get('/users/$id');
  }

  Future<List<dynamic>> getAnime({
    int page = 1,
    int perPage = 24,
    String? status,
    int? releaseYear,
    double? rating,
    String? genres,
    String? sort,
  }) async {
    final params = {'page': '$page', 'per_page': '$perPage'};
    if (status != null) params['status'] = status;
    if (releaseYear != null) params['release_year'] = '$releaseYear';
    if (rating != null) params['rating'] = '$rating';
    if (genres != null) params['genres'] = genres;
    if (sort != null) params['sort'] = sort;
    final data = await get('/anime', params);
    return data != null && data['anime'] != null
        ? data['anime'] as List<dynamic>
        : [];
  }

  Future<List<dynamic>> getOngoingAnime({
    int page = 1,
    int perPage = 24,
  }) async {
    final params = {'page': '$page', 'per_page': '$perPage'};
    final data = await get('/anime/ongoing', params);
    return data != null && data['anime'] != null
        ? data['anime'] as List<dynamic>
        : [];
  }

  Future<Map<String, dynamic>?> getAnimeById(String id) async {
    return await get('/anime/$id');
  }

  Future<List<dynamic>> getEpisodesByAnime(String id) async {
    final data = await get('/anime/$id/episodes');
    return data != null && data['episodes'] != null
        ? data['episodes'] as List<dynamic>
        : [];
  }

  Future<Map<String, dynamic>?> getEpisode(String id) async {
    return await get('/episodes/$id');
  }

  Future<List<dynamic>> getAllEpisodes({int page = 1, int perPage = 24}) async {
    final params = {'page': '$page', 'per_page': '$perPage'};
    final data = await get('/episodes', params);
    return data != null && data['episodes'] != null
        ? data['episodes'] as List<dynamic>
        : [];
  }

  Future<Map<String, dynamic>?> createUser(Map<String, dynamic> body) async {
    return await post('/users', body);
  }

  Future<Map<String, dynamic>?> updateUser(
    String id,
    Map<String, dynamic> body,
  ) async {
    return await put('/users/$id', body);
  }

  Future<Map<String, dynamic>?> search(String q) async {
    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: {'q': q});
    try {
      final res = await _httpGet(uri);
      final parsed = await _tryParseResponse(res);
      if (parsed == null) {
        final retry = await _httpGet(uri);
        return json.decode(retry.body) as Map<String, dynamic>;
      }
      return parsed;
    } catch (e) {
      if (kIsWeb &&
          (e.toString().contains('XMLHttpRequest') ||
              e.toString().contains('CORS') ||
              e.toString().contains('Cross'))) {
        throw Exception('Web network error (possible CORS): $e');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getNews({int page = 1, int perPage = 10}) async {
    final params = {'page': '$page', 'per_page': '$perPage'};
    final data = await get('/news', params);
    return data != null && data['news'] != null
        ? data['news'] as List<dynamic>
        : [];
  }

  Future<Map<String, dynamic>?> getNewsById(String id) async {
    return await get('/news/$id');
  }

  Future<List<dynamic>> getFavorites(String userId) async {
    final data = await get('/users/$userId/favorites');
    return data != null && data['favorites'] != null
        ? data['favorites'] as List<dynamic>
        : [];
  }

  Future<Map<String, dynamic>?> addFavorite(
    String userId,
    String animeId,
  ) async {
    final res = await post('/favorites', {
      'user_id': userId,
      'anime_id': animeId,
    });
    return res;
  }

  Future<bool> removeFavorite(String favoriteId) async {
    return await delete('/favorites/$favoriteId');
  }

  Future<bool> likeEpisode(String episodeId, String userId) async {
    final res = await post('/interactions/episodes/$episodeId/like', {
      'user_id': userId,
    });
    return res != null;
  }

  Future<bool> dislikeEpisode(String episodeId, String userId) async {
    final res = await post('/interactions/episodes/$episodeId/dislike', {
      'user_id': userId,
    });
    return res != null;
  }

  Future<List<dynamic>> getEpisodeComments(String episodeId) async {
    final data = await get('/episodes/$episodeId/comments');
    return data != null && data['comments'] != null
        ? data['comments'] as List<dynamic>
        : [];
  }

  Future<bool> postEpisodeComment(
    String episodeId,
    String userId,
    String content,
  ) async {
    final res = await post('/episodes/$episodeId/comments', {
      'user_id': userId,
      'content': content,
    });
    return res != null;
  }

  Future<List<dynamic>> getUserDevices(String userId) async {
    final data = await get('/users/$userId/devices');
    return data != null && data['devices'] != null
        ? data['devices'] as List<dynamic>
        : [];
  }

  Future<bool> registerDevice(
    String userId,
    String deviceUuid, {
    String? deviceName,
    String? deviceInfo,
    String? platform,
  }) async {
    final res = await post('/devices', {
      'user_id': userId,
      'device_uuid': deviceUuid,
      'device_name': deviceName ?? '',
      'device_info': deviceInfo ?? '',
      'platform': platform ?? (kIsWeb ? 'web' : 'unknown'),
    });
    return res != null && (res['id'] != null || res['message'] != null);
  }

  Future<bool> revokeDevice(String deviceId) async {
    return await delete('/devices/$deviceId');
  }

  Future<Map<String, dynamic>?> checkPromo(String code) async {
    return await post('/promocodes/check', {'code': code});
  }

  Future<Map<String, dynamic>?> applyPromo(String code, String userId) async {
    return await post('/promocodes/apply', {'code': code, 'user_id': userId});
  }

  Future<bool> ping() async {
    try {
      final uri = Uri.parse('https://clients3.google.com/generate_204');
      final res = await _httpGet(uri);
      if (res.statusCode == 204 || res.statusCode == 200) return true;
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
    }

    try {
      final uri = Uri.parse(baseUrl);
      final res = await _httpGet(uri);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
