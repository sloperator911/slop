import 'dart:convert';

import 'package:http/http.dart' as http;

String apiMessage(http.Response response) {
  try {
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final error = data['error'] as Map<String, dynamic>;
    final code = error['code'] as String;

    return switch (code) {
      'VALIDATION_ERROR' => 'Отправленные данные недействительны',
      'UNAUTHORIZED' => 'Неверный email или пароль',
      'EMAIL_TAKEN' => 'Аккаунт с этим email уже существует',
      'NOT_FOUND' => 'Запись не существует',
      'INTERNAL_ERROR' => 'Сервер не смог выполнить запрос',
      _ => 'Ошибка сервера ($code)',
    };
  } on FormatException {
    return 'Ошибка сервера (${response.statusCode})';
  } on TypeError {
    return 'Ошибка сервера (${response.statusCode})';
  }
}
