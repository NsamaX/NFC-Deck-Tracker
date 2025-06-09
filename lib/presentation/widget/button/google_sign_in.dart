import 'package:flutter/material.dart';

import '../../locale/localization.dart';

import '../../../util/google_athen.dart';
import '../constant/image.dart';
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

    switch (await signInWithGoogle()) {
      case 'success':
        handleGuestSignIn(context);
        break;
      case 'cancelled':
        AppSnackBar(
          context,
          text: locale.translate('page_sign_in.snack_bar_sign_in_error_unknow'),
          isError: true,
        );
        break;
      case 'fail':
        AppSnackBar(
          context,
          text: locale.translate('page_sign_in.snack_bar_sign_in_fail'),
          isError: true,
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
        color: theme.colorScheme.surface,
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
      child: Image.asset(ImageConstant.googleLogo, fit: BoxFit.cover),
    );
  }
}
