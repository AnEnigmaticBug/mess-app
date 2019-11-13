import 'dart:convert';

import 'package:http/http.dart';

class Http4xxException implements Exception {
  const Http4xxException(this.statusCode, [this.message]);

  factory Http4xxException.fromResponse(Response response) {
    try {
      final message = json.decode(response.body)['message'];
      return Http4xxException(response.statusCode, message);
    } on Exception {
      return Http4xxException(response.statusCode);
    }
  }

  final int statusCode;
  final String message;

  @override
  String toString() => 'Http4xxException($statusCode): $message';
}

class Http5xxException implements Exception {
  const Http5xxException();

  @override
  String toString() => 'Http5xxException';
}

extension ResponseToExceptionExtension on Response {
  Exception toException() {
    final firstNumber = statusCode.toString()[0];

    if (firstNumber == '4') {
      return Http4xxException.fromResponse(this);
    }

    if (firstNumber == '5') {
      return Http5xxException();
    }

    return Exception('$statusCode error');
  }
}
