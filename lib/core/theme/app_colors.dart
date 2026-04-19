import 'package:flutter/material.dart';

/// Codekata color tokens - sourced from Picasso's design doc.
/// Electric blue identity, gamified DSA learning.
abstract final class AppColors {
  // ── Primary - Electric Blue ──────────────────────────────
  static const primary = Color(0xFF1A8CFF);
  static const primaryDark = Color(0xFF0066CC);
  static const primaryLight = Color(0xFFC8E4FF);
  static const primarySurface = Color(0xFFEEF6FF);

  // ── XP Gold - Streak & Rewards ───────────────────────────
  static const gold = Color(0xFFF5A623);
  static const goldDark = Color(0xFFC97E10);
  static const goldLight = Color(0xFFFEF3DA);

  // ── Success Green (Linear/Arc teal-green) ────────────────
  static const success = Color(0xFF2EC37A);
  static const successDark = Color(0xFF1F8F58);
  static const successLight = Color(0xFFD4F2E3);

  // ── Error Red (Apple-desaturated) ────────────────────────
  static const error = Color(0xFFF14A59);
  static const errorDark = Color(0xFFC62330);
  static const errorLight = Color(0xFFFDE2E5);

  // ── Warning Orange ───────────────────────────────────────
  static const warning = Color(0xFFFF9600);
  static const warningLight = Color(0xFFFFF0D4);

  // ── Neutral / Surface (Light) ────────────────────────────
  static const bg = Color(0xFFF7F9FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEEF1F8);
  static const border = Color(0xFFD8E0EF);
  static const borderStrong = Color(0xFFB0BDD8);

  // ── Text (Light) ────────────────────────────────────────
  static const textPrimary = Color(0xFF1A1F2E);
  static const textSecondary = Color(0xFF6B7A99);
  static const textDisabled = Color(0xFFB0B8CC);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Code Editor (Dark canvas) ───────────────────────────
  static const codeBg = Color(0xFF10121E);
  static const codeBgAlt = Color(0xFF1A1D2E);
  static const codeLineHl = Color(0xFF1F2336);
  static const codeText = Color(0xFFE2E8F8);
  static const codeKeyword = Color(0xFFA78BFA);
  static const codeString = Color(0xFF6EE7A0);
  static const codeNumber = Color(0xFFFBB86C);
  static const codeComment = Color(0xFF5E6885);
  static const codeSlot = Color(0xFF1A8CFF);

  // ── Dark mode overrides ─────────────────────────────────
  static const darkBg = Color(0xFF12141F);
  static const darkSurface = Color(0xFF1C1F30);
  static const darkSurfaceAlt = Color(0xFF222638);
  static const darkBorder = Color(0xFF323752);
  static const darkTextPrimary = Color(0xFFE8EDF8);
  static const darkTextSecondary = Color(0xFF8B96B5);
}
