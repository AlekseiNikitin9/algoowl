import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Codekata typography. Display = Space Grotesk (tight tracking),
/// body = Inter, code = JetBrains Mono.
abstract final class AppTypography {
  // ── Display (Space Grotesk) ──────────────────────────────

  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        height: 38 / 32,
        letterSpacing: -0.02 * 32,
      );

  static TextStyle get h1 => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 26,
        height: 32 / 26,
        letterSpacing: -0.02 * 26,
      );

  static TextStyle get h2 => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 26 / 20,
        letterSpacing: -0.015 * 20,
      );

  static TextStyle get h3 => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w600,
        fontSize: 17,
        height: 22 / 17,
        letterSpacing: -0.01 * 17,
      );

  // ── Body (Inter) ─────────────────────────────────────────

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: -0.005 * 16,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 22 / 15,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        height: 18 / 13,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 16 / 12,
      );

  /// Small-caps eyebrow label (used by section headers).
  static TextStyle get eyebrow => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 14 / 11,
        letterSpacing: 0.14 * 11,
      );

  // ── JetBrains Mono (code editor) ─────────────────────────

  static TextStyle get codeBody => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w400,
        fontSize: 13,
        height: 20 / 13,
        color: AppColors.codeText,
      );

  static TextStyle get codeKeyword => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        height: 20 / 13,
        color: AppColors.codeKeyword,
      );

  static TextStyle get codeSlot => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        height: 20 / 13,
        color: AppColors.codeSlot,
        decoration: TextDecoration.underline,
      );
}
