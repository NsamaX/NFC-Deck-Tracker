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
  final bool isCardChanged;

  const RestartNfcSessionEvent({
    this.card, 
    this.isCardChanged = false,
  });

  @override
  List<Object?> get props => [card, isCardChanged];
}

class ProcessReadTagEvent extends NfcEvent {
  final NfcTag tag;

  const ProcessReadTagEvent({
    required this.tag,
  });

  @override
  List<Object?> get props => [tag];
}

class ProcessWriteTagEvent extends NfcEvent {
  final NfcTag tag;
  final CardEntity card;

  const ProcessWriteTagEvent({
    required this.tag, 
    required this.card,
  });

  @override
  List<Object?> get props => [tag, card];
}

class ClearNFCMessagesEvent extends NfcEvent {}
