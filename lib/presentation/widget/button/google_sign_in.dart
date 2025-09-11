import 'package:flutter/material.dart';

import '../../auth/google.dart';
import '../../auth/guest.dart';
import '../../locale/localization.dart';

import '../notification/snackbar.dart';

class ButtonGoogleSignIn extends StatelessWidget {
  const ButtonGoogleSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleGoogleSignIn(context),
      child: _buildButton(context),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final locale = AppLocalization.of(context);

    final result = await signInWithGoogle();

    switch (result) {
      case SignInResult.success:
        signInAsGuest(context);
        break;
      case SignInResult.cancelledByUser:
        AppSnackBar(
          context,
          text: locale.translate('page_sign_in.snack_bar_sign_in_cancelled'),
          type: SnackBarType.warning,
        );
        break;
      case SignInResult.failed:
        AppSnackBar(
          context,
          text: locale.translate('page_sign_in.snack_bar_sign_in_fail'),
          type: SnackBarType.error,
        );
        break;
    }
  }

  Widget _buildButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface,
            offset: const Offset(1.0, 1.0),
            blurRadius: 3.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Image.asset('assets/image/google-logo.png', fit: BoxFit.cover),
    );
  }
}
