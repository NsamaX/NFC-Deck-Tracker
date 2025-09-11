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
      LoggerUtil.i(buffer.toString());
    } else {
      LoggerUtil.w('Warning: Route arguments is not a Map<String, dynamic>.');
    }
  } else {
    LoggerUtil.i('Route Arguments: null');
  }

  return args is Map<String, dynamic> ? args : {};
}
