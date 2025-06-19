import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

Map<String, dynamic> getArguments(BuildContext context) {
  final args = ModalRoute.of(context)?.settings.arguments;

  if (args != null) {
    if (args is Map<String, dynamic>) {
      final buffer = StringBuffer();
      buffer.writeln('Route Arguments: {');
      args.forEach((key, value) {
        buffer.writeln('    $key: $value,');
      });
      buffer.write('}');
      LoggerUtil.addMessage(buffer.toString());
    } else {
      LoggerUtil.addMessage('Warning: Route arguments is not a Map<String, dynamic>.');
    }
  } else {
    LoggerUtil.addMessage('Route Arguments: null');
  }

  LoggerUtil.flushMessages();
  return args is Map<String, dynamic> ? args : {};
}
