import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'application.dart';
import 'job_filter_options.dart';
import 'job_post.dart';
import 'job_repository.dart';
import 'result.dart';
import 'token_store.dart';

class HttpJobRepository implements JobRepository {
  const HttpJobRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;
  final Future<void> Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${token ?? ''}',
  };

  Future<String> _sessionDied(String? token) async {
    if (await tokens.read() == token) {
      await tokens.clear();
      await onUnauthorized?.call();
    }
    return 'Сессия истекла — войдите снова';
  }

  @override
  Future<Result<List<JobPost>>> getJobs({
    int page = 1,
    int limit = 20,
    String? search,
    String? technology,
    String? schedule,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/job-posts').replace(
        queryParameters: {
          'page': '$page',
          'limit': '$limit',
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (technology != null && technology.isNotEmpty)
            'technology': technology,
          if (schedule != null && schedule.isNotEmpty) 'schedule': schedule,
        },
      );
      final token = await tokens.read();
      final response = await http
          .get(uri, headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 401) {
        return Err(await _sessionDied(token));
      }
      if (response.statusCode != 200) return Err(apiMessage(response));

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Ok(
        (data['items'] as List)
            .map((item) => JobPost.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
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

  @override
  Future<Result<JobPost>> getJob(int id) async {
    try {
      final token = await tokens.read();
      final response = await http
          .get(Uri.parse('$baseUrl/job-posts/$id'), headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 401) {
        return Err(await _sessionDied(token));
      }
      if (response.statusCode == 404) return const Err('Вакансия не найдена');
      if (response.statusCode != 200) return Err(apiMessage(response));

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Ok(JobPost.fromJson(data));
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

  @override
  Future<Result<JobFilterOptions>> getJobFilters() async {
    try {
      final token = await tokens.read();
      final response = await http
          .get(
            Uri.parse('$baseUrl/job-posts/filters'),
            headers: _headers(token),
          )
          .timeout(_timeout);
      if (response.statusCode == 401) {
        return Err(await _sessionDied(token));
      }
      if (response.statusCode != 200) return Err(apiMessage(response));

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Ok(JobFilterOptions.fromJson(data));
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

  @override
  Future<Result<List<Application>>> getApplications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/applications')
          .replace(queryParameters: {'page': '$page', 'limit': '$limit'});
      final token = await tokens.read();
      final response = await http
          .get(uri, headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 401) {
        return Err(await _sessionDied(token));
      }
      if (response.statusCode != 200) return Err(apiMessage(response));

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Ok(
        (data['items'] as List)
            .map((item) => Application.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
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

  @override
  Future<Result<Application>> addApplication({
    required int jobPostId,
    required String cvName,
    required String message,
  }) async {
    try {
      final token = await tokens.read();
      final response = await http
          .post(
            Uri.parse('$baseUrl/applications'),
            headers: _headers(token),
            body: jsonEncode({
              'jobPostId': jobPostId,
              'cvUrl': cvName,
              'message': message,
            }),
          )
          .timeout(_timeout);
      if (response.statusCode == 401) {
        return Err(await _sessionDied(token));
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        return Err(apiMessage(response));
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Ok(Application.fromJson(data));
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
