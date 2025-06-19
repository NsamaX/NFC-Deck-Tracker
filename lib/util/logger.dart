import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerUtil {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printEmojis: false,
    ),
  );

  static final List<String> _messageBuffer = [];

  static void addMessage(String message) {
    if (kDebugMode) {
      _messageBuffer.add(message);
    }
  }

  static void flushMessages({bool isError = false}) {
    if (kDebugMode && _messageBuffer.isNotEmpty) {
      final String log = _messageBuffer.join('\n');
      _logger.log(isError ? Level.error : Level.info, log);
      _messageBuffer.clear();
    }
  }

  static void debugMessage(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
