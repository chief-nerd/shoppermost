import 'package:http/http.dart' as http;
import 'dart:convert';

class MattermostApi {
  late String baseUrl;
  late String token;
  String? userId;

  Future<bool> login(String server, String username, String password) async {
    baseUrl = server;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v4/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login_id': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        token = response.headers['token'] ?? '';
        return true;
      } else {
        print('Login failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String?> getCurrentUserId() async {
    if (userId != null) return userId;

    try {
      final response = await http.get(
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
      print('Failed to get user: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getChannelMessages(String channelId) async {
    final response = await http.get(
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
      posts.sort((a, b) => DateTime.fromMicrosecondsSinceEpoch(a['create_at']).compareTo(DateTime.fromMicrosecondsSinceEpoch(b['create_at'])));
      return List<Map<String, dynamic>>.from(posts);
    }
    return [];
  }

  Future<bool> addReaction(String postId, String emoji) async {
    try {
      final uid = await getCurrentUserId();
      if (uid == null) return false;

      final response = await http.post(
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
      print(response.body);
      return response.statusCode == 201;
    } catch (e) {
      print('Failed to add reaction: $e');
      return false;
    }
  }

  Future<bool> postMessage(String channelId, String message) async {
    try {
      final response = await http.post(
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
      print('Failed to post message: $e');
      return false;
    }
  }
}
