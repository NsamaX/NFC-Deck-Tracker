part of 'nfc_cubit.dart';

class NfcState extends Equatable {
  final bool isSessionActive;
  final bool isSessionBusy;
  final String successMessage;
  final String warningMessage;
  final String errorMessage;
  final TagEntity? lastScannedTag;

  const NfcState({
    this.isSessionActive = false,
    this.isSessionBusy = false,
    this.successMessage = '',
    this.warningMessage = '',
    this.errorMessage = '',
    this.lastScannedTag,
  });

  NfcState copyWith({
    bool? isSessionActive,
    bool? isSessionBusy,
    String? successMessage,
    String? warningMessage,
    String? errorMessage,
    TagEntity? lastScannedTag,
  }) {
    return NfcState(
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isSessionBusy: isSessionBusy ?? this.isSessionBusy,
      successMessage: successMessage ?? this.successMessage,
      warningMessage: warningMessage ?? this.warningMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      lastScannedTag: lastScannedTag ?? this.lastScannedTag,
    );
  }

  @override
  List<Object?> get props => [
        isSessionActive,
        isSessionBusy,
        successMessage,
        warningMessage,
        errorMessage,
        lastScannedTag,
      ];
}
