import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../material/google_athen.dart';
import '../shared/image_constant.dart';
import '../shared/snackbar.dart';

import '../../cubit/application_cubit.dart';
import '../../locale/localization.dart';

class GoogleSignInButtonWidget extends StatelessWidget {
  const GoogleSignInButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleGoogleSignIn(context),
      child: _buildButton(context),
    );
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

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final locale = AppLocalization.of(context);
    final navigator = Navigator.of(context);
    final applicationCubit = context.read<ApplicationCubit>();

    final result = await signInWithGoogle();

    switch (result) {
      case 'success':
        handleGuestSignIn(
          navigator: navigator,
          applicationCubit: applicationCubit,
        );
        break;
      case 'cancelled':
        showAppSnackBar(
          context,
          text: locale.translate('page_sign_in.snack_bar_sign_in_error_unknow'),
          isError: true,
        );
        break;
      case 'fail':
        showAppSnackBar(
          context,
          text: locale.translate('page_sign_in.snack_bar_sign_in_fail'),
          isError: true,
        );
        break;
    }
  }
}
