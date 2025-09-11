import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerUtil {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printEmojis: false,
      noBoxingByDefault: false,
      levelColors: {
        Level.warning: AnsiColor.fg(208),
      },
    ),
  );

  static final List<String> _messageBuffer = [];

  static void d(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static void i(Object message) {
    if (kDebugMode) {
      _logger.i(message);
    }
  }

  static void w(Object message) {
    if (kDebugMode) {
      _logger.w(message);
    }
  }

  static void e(Object message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  static void buffer(String message) {
    if (kDebugMode) {
      _messageBuffer.add(message);
    }
  }

  static void flush({bool asError = false}) {
    if (!_messageBuffer.isNotEmpty) return;

    if (kDebugMode) {
      final fullLog = _messageBuffer.join('\n');
      if (asError) {
        _logger.e(fullLog);
      } else {
        _logger.i(fullLog);
      }
      _messageBuffer.clear();
    }
  }
}
