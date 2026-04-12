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

  // ── Success Green ────────────────────────────────────────
  static const success = Color(0xFF58CC02);
  static const successDark = Color(0xFF3D9900);
  static const successLight = Color(0xFFD7F5B7);

  // ── Error Red ────────────────────────────────────────────
  static const error = Color(0xFFFF4B4B);
  static const errorDark = Color(0xFFCC2020);
  static const errorLight = Color(0xFFFFE0E0);

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

  // ── Code Editor (Dark surface, same for both themes) ────
  static const codeBg = Color(0xFF1A1D2E);
  static const codeLineHl = Color(0xFF252A3D);
  static const codeText = Color(0xFFE2E8F8);
  static const codeKeyword = Color(0xFFA78BFA);
  static const codeString = Color(0xFF6EE7A0);
  static const codeNumber = Color(0xFFFBB86C);
  static const codeComment = Color(0xFF7A8099);
  static const codeSlot = Color(0xFF1A8CFF);

  // ── Dark mode overrides ─────────────────────────────────
  static const darkBg = Color(0xFF12141F);
  static const darkSurface = Color(0xFF1C1F30);
  static const darkSurfaceAlt = Color(0xFF222638);
  static const darkBorder = Color(0xFF323752);
  static const darkTextPrimary = Color(0xFFE8EDF8);
  static const darkTextSecondary = Color(0xFF8B96B5);
}
