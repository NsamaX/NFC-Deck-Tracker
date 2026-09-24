import 'package:equatable/equatable.dart';

class SessionUser extends Equatable {
  final String uid;
  final String? email;
  const SessionUser({required this.uid, this.email});

  @override
  List<Object?> get props => [uid, email];
}

enum SignInResult { success, cancelledByUser, failed }
