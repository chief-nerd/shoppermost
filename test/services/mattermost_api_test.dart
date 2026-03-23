import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:shoppermost/services/mattermost_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('MattermostApi', () {
    test('login success', () async {
      SharedPreferences.setMockInitialValues({});
      
      final client = MockClient((request) async {
        if (request.url.path == '/api/v4/users/login') {
          return http.Response('', 200, headers: {'token': 'test_token'});
        }
        return http.Response('', 404);
      });

      final api = MattermostApi(client: client);
      final result = await api.login('https://chat.example.com', 'user', 'pass');
      
      expect(result, true);
      expect(api.token, 'test_token');
      expect(api.baseUrl, 'https://chat.example.com');
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(MattermostApi.tokenKey), 'test_token');
    });

    test('getChannelMessages parses UTF-8 correctly', () async {
      final utf8String = 'Brötchen & Eier';
      final responseBody = json.encode({
        'posts': {
          'post1': {
            'id': 'post1',
            'message': utf8String,
            'create_at': 1600000000000,
          }
        }
      });

      final client = MockClient((request) async {
        return http.Response.bytes(utf8.encode(responseBody), 200);
      });

      final api = MattermostApi(client: client);
      api.baseUrl = 'https://chat.example.com';
      api.token = 'test_token';
      
      final messages = await api.getChannelMessages('channel1');
      
      expect(messages.length, 1);
      expect(messages[0]['message'], utf8String);
    });

    test('addReaction success', () async {
       final client = MockClient((request) async {
        if (request.url.path == '/api/v4/users/me') {
          return http.Response(json.encode({'id': 'user1'}), 200);
        }
        if (request.url.path == '/api/v4/reactions' && request.method == 'POST') {
          return http.Response('', 201);
        }
        return http.Response('', 404);
      });

      final api = MattermostApi(client: client);
      api.baseUrl = 'https://chat.example.com';
      api.token = 'test_token';
      
      final result = await api.addReaction('post1', 'thumbsup');
      expect(result, true);
    });
  });
}
