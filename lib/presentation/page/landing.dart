import 'package:flutter/material.dart';

import '../locale/localization.dart';
import '../route/route_constant.dart';
import '../widget/shared/button_width_max.dart';
import '../widget/shared/description_align_center.dart';
import '../widget/shared/image_constant.dart';
import '../widget/shared/title_align_center.dart';
import '../widget/shared/ui_constant.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

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
            ButtonWidthMax(
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
