import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../auth/google.dart';
import '../locale/localization.dart';
import '../route/route_constant.dart';
import '../widget/button/max_width.dart';
import '../widget/constant/image.dart';
import '../widget/constant/ui.dart';
import '../widget/text/description_align_center.dart';
import '../widget/text/title_align_center.dart';

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
      await googleSignOut();
      LoggerUtil.debugMessage('User signed out automatically on LandingPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstant.paddingAround,
          vertical: UIConstant.paddingVertical,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TitleAlignCenter(
              text: locale.translate('page_landing.app_name'),
            ),
            Image.asset(
              ImageConstant.landingPage,
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
