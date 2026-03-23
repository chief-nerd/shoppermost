import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MattermostApi {
  late String baseUrl;
  late String token;
  String? userId;
  final http.Client _client;

  MattermostApi({http.Client? client}) : _client = client ?? http.Client();

  static const String tokenKey = 'mattermost_token';
  static const String serverKey = 'mattermost_server';
  static const String channelKey = 'mattermost_channel_id';

  Future<bool> hasStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(tokenKey);
    final storedServer = prefs.getString(serverKey);
    if (storedToken != null && storedServer != null) {
      token = storedToken;
      baseUrl = storedServer.endsWith('/')
          ? storedServer.substring(0, storedServer.length - 1)
          : storedServer;
      return true;
    }
    return false;
  }

  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(serverKey, baseUrl);
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(serverKey);
  }

  Future<bool> login(String server, String username, String password) async {
    baseUrl =
        server.endsWith('/') ? server.substring(0, server.length - 1) : server;
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/v4/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login_id': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        token = response.headers['token'] ?? '';
        await saveCredentials();
        return true;
      } else {
        log('Login failed with status code: ${response.statusCode}',
            name: 'MattermostApi');
        log('Response body: ${response.body}', name: 'MattermostApi');
        return false;
      }
    } catch (e) {
      log('Login error: $e', name: 'MattermostApi', error: e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getMyChannels() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v4/users/me/channels'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List channels = json.decode(utf8.decode(response.bodyBytes));
        // Filter to non-DM/GM channels and sort by display name
        final filtered = channels
            .where((c) => c['type'] == 'O' || c['type'] == 'P')
            .map((c) => {
                  'id': c['id'] as String,
                  'name': c['name'] as String,
                  'display_name': c['display_name'] as String,
                })
            .toList();
        filtered.sort((a, b) => (a['display_name'] as String)
            .compareTo(b['display_name'] as String));
        return List<Map<String, dynamic>>.from(filtered);
      }
    } catch (e) {
      log('Failed to fetch channels: $e', name: 'MattermostApi', error: e);
    }
    return [];
  }

  Future<void> saveChannelId(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(channelKey, channelId);
  }

  Future<String?> getSavedChannelId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(channelKey);
  }

  Future<String?> getCurrentUserId() async {
    if (userId != null) return userId;

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v4/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        userId = data['id'];
        return userId;
      }
    } catch (e) {
      log('Failed to get user: $e', name: 'MattermostApi', error: e);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getChannelMessages(
      String channelId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v4/channels/$channelId/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      // Explicitly decode as UTF-8
      final data = json.decode(utf8.decode(response.bodyBytes));

      final posts = (data['posts'] as Map<String, dynamic>).values.toList();
      posts.sort((a, b) => DateTime.fromMicrosecondsSinceEpoch(a['create_at'])
          .compareTo(DateTime.fromMicrosecondsSinceEpoch(b['create_at'])));
      return List<Map<String, dynamic>>.from(posts);
    }
    return [];
  }

  Future<bool> addReaction(String postId, String emoji) async {
    try {
      final uid = await getCurrentUserId();
      if (uid == null) return false;

      final response = await _client.post(
        Uri.parse('$baseUrl/api/v4/reactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': uid,
          'post_id': postId,
          'emoji_name': emoji,
        }),
      );
      log('Add reaction response: ${response.body}', name: 'MattermostApi');
      return response.statusCode == 201;
    } catch (e) {
      log('Failed to add reaction: $e', name: 'MattermostApi', error: e);
      return false;
    }
  }

  Future<bool> postMessage(String channelId, String message) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/v4/posts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'channel_id': channelId,
          'message': message,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      log('Failed to post message: $e', name: 'MattermostApi', error: e);
      return false;
    }
  }
}
