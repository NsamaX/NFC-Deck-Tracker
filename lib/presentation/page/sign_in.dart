import 'package:flutter/material.dart';
import '../dependencies.dart';

import '../locale/localization.dart';
import '../widget/button/google_sign_in.dart';
import '../widget/button/guest_sign_in.dart';
import '../widget/text/description_align_center.dart';
import '../widget/text/title_align_center.dart';
import '../constant.dart';
import '../../.config/runtime.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      body: StreamBuilder<bool>(
        stream: PresentationScope.read(context).device.connectivityChanges,
        initialData: false,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final isOnline = snapshot.data!;

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
