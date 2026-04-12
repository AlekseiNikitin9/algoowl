import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens per Picasso's design doc.
/// Primary: Nunito, Code: JetBrains Mono.
///
/// Body/heading styles intentionally omit [color] so they inherit from the
/// current [Theme], making them work in both light and dark mode.
abstract final class AppTypography {
  // ── Nunito styles ────────────────────────────────────────

  static TextStyle get display => GoogleFonts.nunito(
        fontWeight: FontWeight.w900,
        fontSize: 32,
        height: 38 / 32,
      );

  static TextStyle get h1 => GoogleFonts.nunito(
        fontWeight: FontWeight.w800,
        fontSize: 26,
        height: 32 / 26,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        height: 26 / 20,
      );

  static TextStyle get h3 => GoogleFonts.nunito(
        fontWeight: FontWeight.w700,
        fontSize: 17,
        height: 22 / 17,
      );

  static TextStyle get bodyLg => GoogleFonts.nunito(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 24 / 16,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 22 / 15,
      );

  static TextStyle get label => GoogleFonts.nunito(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        height: 18 / 13,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 16 / 12,
      );

  // ── JetBrains Mono styles (code editor) ──────────────────
  // These keep explicit colors - always shown on dark code bg.

  static TextStyle get codeBody => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 20 / 14,
        color: AppColors.codeText,
      );

  static TextStyle get codeKeyword => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 20 / 14,
        color: AppColors.codeKeyword,
      );

  static TextStyle get codeSlot => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 20 / 14,
        color: AppColors.codeSlot,
        decoration: TextDecoration.underline,
      );
}
