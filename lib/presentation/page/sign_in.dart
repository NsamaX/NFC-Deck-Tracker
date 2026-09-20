import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../locale/localization.dart';
import '../widget/button/google_sign_in.dart';
import '../widget/button/guest_sign_in.dart';
import '../widget/text/description_align_center.dart';
import '../widget/text/title_align_center.dart';
import '../constant.dart';
import '../../.config/runtime.dart';
import '../bloc/application/bloc.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      body: BlocSelector<ApplicationBloc, ApplicationState, bool>(
        selector: (state) => state.isOnline,
        builder: (context, isOnline) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: WidgetConstant.paddingAround,
              vertical: WidgetConstant.paddingVertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TitleAlignCenter(
                  text: locale.translate('page_sign_in.title'),
                ),
                if (isOnline && !RuntimeConfig.guestMode) ...[
                  const SizedBox(height: 80.0),
                  const ButtonGoogleSignIn(),
                  const SizedBox(height: 80.0),
                ] else if (!RuntimeConfig.guestMode) ...[
                  Image.asset(
                    'assets/image/internet-lost.png',
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20.0),
                  DescriptionAlignCenter(
                    text: locale.translate('page_sign_in.offline_message'),
                  ),
                  const SizedBox(height: 20.0),
                ],
                ButtonGuestSignIn(
                  text: locale.translate('page_sign_in.button_guest_sign_in'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
