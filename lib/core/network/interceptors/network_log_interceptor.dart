import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkLogInterceptor extends Interceptor {
  NetworkLogInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('*** Request ***');
    _log('uri: ${options.uri}');
    _log('method: ${options.method}');
    _log('responseType: ${options.responseType}');
    _log('followRedirects: ${options.followRedirects}');
    _log('persistentConnection: ${options.persistentConnection}');
    _log('connectTimeout: ${options.connectTimeout}');
    _log('sendTimeout: ${options.sendTimeout}');
    _log('receiveTimeout: ${options.receiveTimeout}');
    _log('receiveDataWhenStatusError: ${options.receiveDataWhenStatusError}');
    _log('extra: ${options.extra}');
    _log('headers:');
    final headers = _formatHeaders(options.headers);
    for (final entry in headers.entries) {
      _log(' ${entry.key}: ${entry.value}');
    }
    _log('data:');
    _log(_formatData(options.data));

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('*** Response ***');
    _log('uri: ${response.requestOptions.uri}');
    _log('statusCode: ${response.statusCode}');
    _log('data:');
    _log(_safeToString(response.data));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('*** DioError ***');
    _log('uri: ${err.requestOptions.uri}');
    _log('type: ${err.type}');
    _log('message: ${err.message}');
    if (err.response != null) {
      _log('statusCode: ${err.response?.statusCode}');
      _log('data:');
      _log(_safeToString(err.response?.data));
    }
    handler.next(err);
  }

  void _log(String message) {
    if (kDebugMode || kProfileMode) {
      debugPrint(message, wrapWidth: 1024);
    }
  }

  Map<String, dynamic> _formatHeaders(Map<String, dynamic> headers) {
    final out = <String, dynamic>{};
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization' && entry.value is String) {
        out[entry.key] = _maskAuthorization(entry.value as String);
      } else {
        out[entry.key] = entry.value;
      }
    }
    return out;
  }

  String _maskAuthorization(String value) {
    final trimmed = value.trim();
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts.first} ***';
    return '***';
  }

  String _formatData(dynamic data) {
    if (data == null) return 'null';

    if (data is FormData) {
      final b = StringBuffer();
      if (data.fields.isEmpty && data.files.isEmpty) return '(empty FormData)';

      if (data.fields.isNotEmpty) {
        b.writeln('FormData fields:');
        for (final field in data.fields) {
          b.writeln(' - ${field.key}: ${field.value}');
        }
      }

      if (data.files.isNotEmpty) {
        if (data.fields.isNotEmpty) b.writeln();
        b.writeln('FormData files:');
        for (final fileEntry in data.files) {
          final file = fileEntry.value;
          b.writeln(
            ' - ${fileEntry.key}: filename=${file.filename ?? '(none)'} length=${file.length} contentType=${file.contentType}',
          );
        }
      }
      return b.toString().trimRight();
    }

    return _safeToString(data);
  }

  String _safeToString(dynamic value) {
    try {
      return value.toString();
    } catch (_) {
      return '<unprintable>';
    }
  }
}
