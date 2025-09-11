part of 'bloc.dart';

class NfcState extends Equatable {
  final TagEntity? lastScannedTag;
  final bool isSessionActive;
  final bool isSessionBusy;
  final String successMessage;
  final String warningMessage;
  final String errorMessage;

  const NfcState({
    this.lastScannedTag,
    this.isSessionActive = false,
    this.isSessionBusy = false,
    this.successMessage = '',
    this.warningMessage = '',
    this.errorMessage = '',
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
      lastScannedTag: lastScannedTag ?? this.lastScannedTag,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isSessionBusy: isSessionBusy ?? this.isSessionBusy,
      successMessage: successMessage ?? this.successMessage,
      warningMessage: warningMessage ?? this.warningMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        lastScannedTag,
        isSessionActive,
        isSessionBusy,
        successMessage,
        warningMessage,
        errorMessage,
      ];
}
