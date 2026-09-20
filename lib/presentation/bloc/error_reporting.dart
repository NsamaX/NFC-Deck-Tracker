import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class ErrorKeys {
  static const load = 'common.error_load';
  static const save = 'common.error_save';
  static const delete = 'common.error_delete';
  static const share = 'common.error_share';
  static const import = 'common.error_import';
}

mixin ErrorReporting<E, S> on Bloc<E, S> {
  S withError(S state, String messageKey);

  Future<void> guard(
    Emitter<S> emit,
    String messageKey,
    Future<void> Function() body,
  ) async {
    emit(withError(state, ''));
    try {
      await body();
    } catch (error, stackTrace) {
      LoggerUtil.e('$runtimeType failed ($messageKey)',
          error: error, stackTrace: stackTrace);
      emit(withError(state, messageKey));
    }
  }
}
