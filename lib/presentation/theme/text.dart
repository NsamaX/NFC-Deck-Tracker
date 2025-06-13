import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:google_fonts/google_fonts.dart';

import 'color.dart';

class AppTextStyles {
  final bool isDark;

  AppTextStyles(this.isDark);

  Color get _textColor => isDark 
      ? AppColor.dark_text
      : AppColor.light_text;

  TextStyle get titleLarge  => _textStyle(color: _textColor, fontSize: 60, isBold: true);
  TextStyle get titleMedium => _textStyle(color: _textColor, fontSize: 20, isBold: true);
  TextStyle get titleSmall  => _textStyle(color: _textColor, fontSize: 10, isBold: true);

  TextStyle get bodyLarge   => _textStyle(color: _textColor, fontSize: 30);
  TextStyle get bodyMedium  => _textStyle(color: _textColor, fontSize: 14);
  TextStyle get bodySmall   => _textStyle(color: _textColor, fontSize: 10);

  TextStyle _textStyle({
    required Color color, 
    required double fontSize, 
    bool isBold = false,
  }) => TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    // fontFamily: GoogleFonts.inter().fontFamily,
    fontFamily: 'PlaypenSansThai',
  );
}
