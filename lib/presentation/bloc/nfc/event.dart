part of 'bloc.dart';

abstract class NfcEvent extends Equatable {
  const NfcEvent();

  @override
  List<Object?> get props => [];
}

class StartNfcSessionEvent extends NfcEvent {
  final CardEntity? card;

  const StartNfcSessionEvent({
    this.card,
  });

  @override
  List<Object?> get props => [card];
}

class StopNfcSessionEvent extends NfcEvent {
  final String reason;

  const StopNfcSessionEvent({
    this.reason = 'User stopped NFC session',
  });

  @override
  List<Object?> get props => [reason];
}

class RestartNfcSessionEvent extends NfcEvent {
  final CardEntity? card;

  const RestartNfcSessionEvent({
    this.card,
  });

  @override
  List<Object?> get props => [card];
}

class NfcResultEvent extends NfcEvent {
  final NfcResult result;
  const NfcResultEvent(this.result);
  @override
  List<Object?> get props => [result];
}

class ClearNFCMessagesEvent extends NfcEvent {}
