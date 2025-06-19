import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/application.dart';
import '../../locale/localization.dart';
import '../../theme/@theme.dart';

import '../constant/image.dart';

class TutorailNFCIcon extends StatefulWidget {
  const TutorailNFCIcon({super.key});

  @override
  State<TutorailNFCIcon> createState() => _TutorailNFCIconState();
}

class _TutorailNFCIconState extends State<TutorailNFCIcon> {
  int _currentPage = 0;

  void _handleTap() {
    setState(() {
      if (_currentPage == 0) {
        _currentPage = 1;
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.read<ApplicationCubit>().state.isDark;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildTooltipCard(context, theme, isDark),
                  _buildTooltipArrow(theme, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipCard(BuildContext context, ThemeData theme, bool isDark) {
    final locale = AppLocalization.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.tutorial : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _currentPage == 1 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            locale.translate(
              _currentPage == 0
                  ? 'page_deck_builder.tutorail_nfc_icon'
                  : 'page_deck_builder.tutorail_how_nfc',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (_currentPage == 1) _buildImagePreview(),
          _buildAnimatedPageIndicator(theme),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        ImageConstant.howToNFC,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  Widget _buildAnimatedPageIndicator(ThemeData theme) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      alignment: _currentPage == 0 ? Alignment.bottomRight : Alignment.topRight,
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: _buildPageIndicator(theme),
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    final isFirstPage = _currentPage == 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIndicatorItem(
          isActive: isFirstPage,
          isLong: true,
          theme: theme,
        ),
        const SizedBox(width: 6.0),
        _buildIndicatorItem(
          isActive: !isFirstPage,
          isLong: false,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildIndicatorItem({
    required bool isActive,
    required bool isLong,
    required ThemeData theme,
  }) {
    return Container(
      width: isLong ? 22.0 : 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: isActive
            ? theme.textTheme.bodyMedium?.color
            : theme.colorScheme.opacity_text,
        borderRadius:
            isLong ? BorderRadius.circular(4.0) : BorderRadius.circular(50),
      ),
    );
  }

  Widget _buildTooltipArrow(ThemeData theme, bool isDark) {
    return Positioned(
      top: -10,
      left: 10,
      child: CustomPaint(
        size: const Size(20, 10),
        painter: _TooltipArrowPainter(
          color: isDark ? theme.colorScheme.tutorial : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _TooltipArrowPainter extends CustomPainter {
  final Color color;

  _TooltipArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
