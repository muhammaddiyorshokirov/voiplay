import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthService extends ChangeNotifier {
  final ApiService api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? userId;
  String? email;
  String? username;
  String? avatar;
  bool premium = false;
  List<String> favorites = [];
  List<String> history = [];

  String? deviceId;
  bool initialized = false;

  AuthService({required this.api}) {
    _loadFromStorage();
  }

  bool get isLoggedIn => userId != null;
  bool get isInitialized => initialized;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = await _storage.read(key: 'user_id');
      email = await _storage.read(key: 'user_email');
      username = await _storage.read(key: 'user_username');
      avatar = await _storage.read(key: 'user_avatar');
      premium = prefs.getBool('user_premium') ?? false;
      favorites = prefs.getStringList('user_favorites') ?? [];
      history = prefs.getStringList('watch_history') ?? [];

      await api.loadTokensFromStorage();

      deviceId = await _storage.read(key: 'device_id');
      if (deviceId == null) {
        deviceId =
            '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}';
        await _storage.write(key: 'device_id', value: deviceId!);
      }

      final lastActiveStr = await _storage.read(key: 'last_active');
      if (lastActiveStr != null && userId != null) {
        final lastActive = DateTime.tryParse(lastActiveStr);
        if (lastActive != null) {
          final diff = DateTime.now().difference(lastActive);
          if (diff.inDays > 30) {
            await logout();
            return;
          }
        }
      }

      if (userId != null) {
        await _fetchUserData();
        await updateLastActive();
        try {
          await api.registerDevice(
            userId!,
            deviceId!,
            platform: kIsWeb ? 'web' : 'unknown',
          );
        } catch (e) {
          final _ = e;
        }
      }

      initialized = true;
      notifyListeners();
    } catch (e) {
      final _ = e;
    }
  }

  Future<void> _fetchUserData() async {
    try {
      if (userId != null) {
        final user = await api.getUserById(userId!);
        if (user != null) {
          username = user['username'];
          avatar = user['avatar'];
          premium = user['premium_status'] ?? false;
          await _saveToStorage();
        }
      }
    } catch (e) {
      final _ = e;
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (userId != null) {
        await _storage.write(key: 'user_id', value: userId!);
      }
      if (email != null) {
        await _storage.write(key: 'user_email', value: email!);
      }
      if (username != null) {
        await _storage.write(key: 'user_username', value: username!);
      }
      if (avatar != null) {
        await _storage.write(key: 'user_avatar', value: avatar!);
      }
      await prefs.setBool('user_premium', premium);
      await prefs.setStringList('user_favorites', favorites);
      await prefs.setStringList('watch_history', history);
    } catch (e) {
      final _ = e;
    }
  }

  Future<bool> checkEmailExists(String e) async {
    final res = await api.search(e);
    return res != null &&
        res['users'] != null &&
        (res['users'] as List).isNotEmpty;
  }

  Future<void> register(String e, String password) async {
    final res = await api.createUser({
      'username': e.split('@').first,
      'email': e,
      'password': password,
    });
    if (res != null && res['id'] != null) {
      userId = res['id'] as String;
      email = e;
      username = e.split('@').first;
      await _saveToStorage();
      await login(e, password);
      notifyListeners();
    }
  }

  Future<bool> login(String e, String password) async {
    try {
      final res = await api.login(e, password);
      if (res != null &&
          res['access_token'] != null &&
          res['refresh_token'] != null) {
        final access = res['access_token'] as String;
        final refresh = res['refresh_token'] as String;
        api.setAuthTokens(accessToken: access, refreshToken: refresh);
        // find user id by search
        final s = await api.search(e);
        if (s != null &&
            s['users'] != null &&
            (s['users'] as List).isNotEmpty) {
          final user = (s['users'] as List).first as Map<String, dynamic>;
          userId = user['id'] as String?;
          email = user['email'] as String? ?? e;
          username = user['username'] as String?;
          avatar = user['avatar'] as String?;
          await _saveToStorage();
          // ensure device id
          deviceId = await _getOrCreateDeviceId();
          if (userId != null && deviceId != null) {
            try {
              await api.registerDevice(
                userId!,
                deviceId!,
                platform: kIsWeb ? 'web' : 'unknown',
              );
            } catch (e) {
              final _ = e;
            }
          }
          await updateLastActive();
          await _fetchUserData();
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      final _ = e;
    }
    return false;
  }

  Future<void> logout() async {
    try {
      userId = null;
      email = null;
      username = null;
      avatar = null;
      premium = false;
      favorites = [];
      history = [];
      await _storage.delete(key: 'user_password');
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_username');
      await _storage.delete(key: 'user_avatar');
      await _storage.delete(key: 'last_active');
      await api.clearAuthTokens();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_premium');
      await prefs.remove('user_favorites');
      await prefs.remove('user_history');
      notifyListeners();
    } catch (e) {
      final _ = e;
    }
  }

  void addToFavorites(String animeId) async {
    if (!favorites.contains(animeId)) {
      favorites.add(animeId);
      notifyListeners();
      await _saveToStorage();
      if (userId != null) {
        try {
          final res = await api.addFavorite(userId!, animeId);
          if (res == null) {
            favorites.remove(animeId);
            await _saveToStorage();
            notifyListeners();
          } else {
            final serverFavs = await api.getFavorites(userId!);
            try {
              favorites = serverFavs
                  .map<String>((f) => f['anime_id'].toString())
                  .toList();
              await _saveToStorage();
              notifyListeners();
            } catch (e) {
              if (kDebugMode) debugPrint(e.toString());
            }
          }
        } catch (e) {}
      }
    }
  }

  void removeFromFavorites(String animeId) async {
    if (favorites.contains(animeId)) {
      favorites.remove(animeId);
      notifyListeners();
      await _saveToStorage();
      if (userId != null) {
        try {
          final serverFavs = await api.getFavorites(userId!);
          final match = serverFavs.firstWhere(
            (f) => f['anime_id']?.toString() == animeId.toString(),
            orElse: () => null,
          );
          if (match != null && match['id'] != null) {
            await api.removeFavorite(match['id'].toString());
          }
        } catch (e) {}
      }
    }
  }

  bool isFavorite(String animeId) {
    return favorites.contains(animeId);
  }

  void addToHistory(String episodeId) async {
    if (history.contains(episodeId)) {
      history.remove(episodeId);
    }
    history.insert(0, episodeId);
    if (history.length > 20) {
      history.removeLast();
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> updateAvatar(String newAvatar) async {
    try {
      if (userId != null) {
        await api.updateUser(userId!, {'avatar': newAvatar});
        avatar = newAvatar;
        await _saveToStorage();
        notifyListeners();
      }
    } catch (e) {
      final _ = e;
    }
  }

  Future<void> setPremium(bool value) async {
    premium = value;
    await _saveToStorage();
    notifyListeners();
  }

  Future<String?> _getOrCreateDeviceId() async {
    try {
      var id = await _storage.read(key: 'device_id');
      if (id == null) {
        id =
            '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}';
        await _storage.write(key: 'device_id', value: id);
      }
      deviceId = id;
      return id;
    } catch (e) {
      final _ = e;
      return null;
    }
  }

  Future<void> updateLastActive() async {
    try {
      await _storage.write(
        key: 'last_active',
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      final _ = e;
    }
  }
}
