part of 'sign_out_cubit.dart';

class SignOutState extends Equatable {
  final bool isLoading;
  final String errorMessage;

  const SignOutState({
    this.isLoading = false,
    this.errorMessage = '',
  });

  SignOutState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return SignOutState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
      ];
}
