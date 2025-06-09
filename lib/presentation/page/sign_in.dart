import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../locale/localization.dart';
import '../widget/constant/image.dart';
import '../widget/constant/ui.dart';
import '../widget/button/google_sign_in.dart';
import '../widget/button/guest_sign_in.dart';
import '../widget/text/description_align_center.dart';
import '../widget/text/title_align_center.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      body: StreamBuilder<List<ConnectivityResult>>(
        stream: Connectivity().onConnectivityChanged,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final results = snapshot.data!;
          final isOnline = results.any(
            (result) => result != ConnectivityResult.none,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstant.paddingAround,
              vertical: UIConstant.paddingVertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TitleAlignCenter(
                  text: locale.translate('page_sign_in.title'),
                ),
                if (isOnline) ...[
                  const SizedBox(height: 80.0),
                  const ButtonGoogleSignIn(),
                  const SizedBox(height: 80.0),
                ] else ...[
                  Image.asset(
                    ImageConstant.internetLost,
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
