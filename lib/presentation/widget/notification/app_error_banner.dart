import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/application/bloc.dart';
import '../../locale/localization.dart';

class AppErrorBanner extends StatelessWidget {
  final Widget child;

  const AppErrorBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ApplicationBloc, ApplicationState, String>(
      selector: (state) => state.errorMessage,
      builder: (context, errorMessage) {
        if (errorMessage.isEmpty) return child;
        final theme = Theme.of(context);
        return Column(
          children: [
            Material(
              color: theme.colorScheme.errorContainer,
              child: SafeArea(
                bottom: false,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer),
                  title: Text(
                    AppLocalization.of(context).translate(errorMessage),
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close,
                        color: theme.colorScheme.onErrorContainer),
                    onPressed: () => context
                        .read<ApplicationBloc>()
                        .add(DismissApplicationErrorEvent()),
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
