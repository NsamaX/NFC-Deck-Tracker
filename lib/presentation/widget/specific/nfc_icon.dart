import 'package:flutter/material.dart';

import '../constant/ui.dart';

class NfcIcon extends StatelessWidget {
  final bool isSessionActive;
  final VoidCallback onTap;

  const NfcIcon({
    super.key,
    required this.isSessionActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = isSessionActive
        ? theme.colorScheme.primary
        : theme.appBarTheme.backgroundColor ?? Colors.grey;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(angle: -90, offsetX: UIConstant.NfcButtonDot + 6, color: color),
            const SizedBox(width: 4),
            _buildDot(color),
            const SizedBox(width: 4),
            _buildIcon(angle: 90, offsetX: -UIConstant.NfcButtonDot - 6, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon({
    required double angle,
    required double offsetX,
    required Color color,
  }) {
    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: AnimatedRotation(
        duration: UIConstant.NfcTransitionDuration,
        turns: angle / 360,
        curve: Curves.easeInOut,
        child: Icon(Icons.wifi_rounded, size: UIConstant.NfcButtonIcon, color: color),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return AnimatedContainer(
      duration: UIConstant.NfcTransitionDuration,
      curve: Curves.easeInOut,
      width: UIConstant.NfcButtonDot,
      height: UIConstant.NfcButtonDot,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
