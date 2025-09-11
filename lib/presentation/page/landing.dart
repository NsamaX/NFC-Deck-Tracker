import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../auth/google.dart';
import '../locale/localization.dart';
import '../route/constant.dart';
import '../widget/button/max_width.dart';
import '../widget/text/description_align_center.dart';
import '../widget/text/title_align_center.dart';
import '../constant.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _signOutIfLoggedIn();
  }

  Future<void> _signOutIfLoggedIn() async {
    final user = locator<FirebaseAuth>().currentUser;
    if (user != null) {
      await signInWithGoogle();
      LoggerUtil.w('User signed out automatically on LandingPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: WidgetConstant.paddingAround,
          vertical: WidgetConstant.paddingVertical,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TitleAlignCenter(
              text: locale.translate('page_landing.app_name'),
            ),
            Image.asset(
              'assets/image/landing-page.png',
              fit: BoxFit.cover,
            ),
            DescriptionAlignCenter(
              text: locale.translate('page_landing.app_description'),
            ),
            ButtonMaxWidth(
              text: locale.translate('page_landing.button_get_started'),
              onPressed: () {
                Navigator.of(context).pushNamed(RouteConstant.sign_in);
              },
            ),
          ],
        ),
      ),
    );
  }
}
