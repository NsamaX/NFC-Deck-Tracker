import 'package:flutter/material.dart';

import '../locale/localization.dart';
import '../widget/button/max_width.dart';
import '../widget/constant/image.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 120.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '404',
              style: theme.textTheme.titleLarge,
            ),
            Text(
              locale.translate('page_not_found.title'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 40.0),
            Image.asset(
              ImageConstant.pageNotFound,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 40.0),
            Navigator.canPop(context)
                ? ButtonMaxWidth(
                    text: locale.translate('page_not_found.button_back'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                : const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
