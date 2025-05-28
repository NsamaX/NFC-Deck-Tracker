part of 'nfc_cubit.dart';

class NfcState extends Equatable {
  final bool isSessionActive;
  final bool isSessionBusy;
  final String errorMessage;
  final String successMessage;

  final TagEntity? lastScannedTag;

  const NfcState({
    this.isSessionActive = false,
    this.isSessionBusy = false,
    this.errorMessage = '',
    this.successMessage = '',
    this.lastScannedTag,
  });

  NfcState copyWith({
    bool? isSessionActive,
    bool? isSessionBusy,
    String? errorMessage,
    String? successMessage,
    TagEntity? lastScannedTag,
  }) {
    return NfcState(
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isSessionBusy: isSessionBusy ?? this.isSessionBusy,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      lastScannedTag: lastScannedTag ?? this.lastScannedTag,
    );
  }

  @override
  List<Object?> get props => [
        isSessionActive,
        isSessionBusy,
        errorMessage,
        successMessage,
        lastScannedTag,
      ];
}
