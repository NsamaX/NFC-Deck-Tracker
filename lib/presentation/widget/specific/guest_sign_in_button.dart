import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../material/google_athen.dart';

import '../../cubit/application_cubit.dart';

class GuestSignInButtonWidget extends StatelessWidget {
  final String text;

  const GuestSignInButtonWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ApplicationCubit applicationCubit = context.read<ApplicationCubit>();

    return SizedBox(
      width: double.infinity,
      height: 46.0,
      child: ElevatedButton(
        onPressed: () => handleGuestSignIn(
          navigator: Navigator.of(context),
          applicationCubit: applicationCubit,
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }
}
