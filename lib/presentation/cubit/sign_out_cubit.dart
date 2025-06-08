import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/usecase/clear_local_datasource.dart';

part 'sign_out_state.dart';

class SignOutCubit extends Cubit<SignOutState> {
  final ClearLocalDataSourceUsecase clearLocalDataSourceUsecase;

  SignOutCubit({
    required this.clearLocalDataSourceUsecase,
  }) : super(const SignOutState());

  void signOut() {
    clearLocalDataSourceUsecase.call();
  }
}
