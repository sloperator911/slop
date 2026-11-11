import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';
import 'user.dart';

class AuthApi {
  const AuthApi(this.baseUrl, this.tokens);

  final String baseUrl;
  final TokenStore tokens;

  static const _timeout = Duration(seconds: 8);

  Future<Result<User>> register(String email, String password, String name) =>
      _post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
      });

  Future<Result<User>> login(String email, String password) =>
      _post('/auth/login', {'email': email, 'password': password});

  Future<void> logout() => tokens.clear();

  Future<Result<User>> _post(String path, Map<String, Object?> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (response.statusCode != 200 && response.statusCode != 201) {
        return Err(apiMessage(response));
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      if (token.isEmpty) {
        return const Err('Ответ не тот, что обещан');
      }
      await tokens.save(token);
      return Ok(user);
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }

  Future<Result<User>> me() async {
    try {
      final token = await tokens.read();
      final response = await http
          .get(
            Uri.parse('$baseUrl/me'),
            headers: {'Authorization': 'Bearer ${token ?? ''}'},
          )
          .timeout(_timeout);
      if (response.statusCode == 401) {
        if (await tokens.read() == token) await tokens.clear();
        return const Err('Сессия истекла — войдите снова');
      }
      if (response.statusCode != 200) {
        return Err(apiMessage(response));
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Ok(User.fromJson(data));
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }
}
