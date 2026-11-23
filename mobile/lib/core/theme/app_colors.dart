import 'package:material_ui/material_ui.dart';

/// Foxio Color Palette — "Cozy Fox Paper"
/// Referensi lengkap: docs/DESIGN_SYSTEM.md
class AppColors {
  AppColors._();

  // Brand / Mascot Colors (Mini Fox)
  static const Color primary = Color(0xFFE07A5F);        // Muted Fox Terracotta
  static const Color primaryLight = Color(0xFFFBECE7);   // Blush Peach
  static const Color primaryDark = Color(0xFFC86248);    // Deep Terracotta

  // Growth & Gamification
  static const Color secondary = Color(0xFF81B29A);      // Muted Sage Green
  static const Color secondaryLight = Color(0xFFEAF4EE); // Mint Whisper
  static const Color streak = Color(0xFFE9B872);         // Warm Honey
  static const Color streakLight = Color(0xFFFDF5E6);    // Butter Cream

  // Backgrounds & Surfaces (Warm Digital Paper)
  static const Color background = Color(0xFFFAF7F2);     // Warm Paper Cream
  static const Color surface = Color(0xFFFFFFFF);        // Pure Warm White
  static const Color surfaceVariant = Color(0xFFF3EDE4); // Soft Sand

  // Typography (Warm Neutrals)
  static const Color textPrimary = Color(0xFF2F2A26);    // Warm Charcoal
  static const Color textSecondary = Color(0xFF78716C);  // Warm Taupe
  static const Color textMuted = Color(0xFFA8A29E);      // Soft Stone

  // Semantic Status
  static const Color success = Color(0xFF81B29A);        // Muted Sage Green
  static const Color error = Color(0xFFD66853);          // Dusty Coral
  static const Color info = Color(0xFF6B9AC4);           // Soft Slate Blue

  // Borders & Dividers
  static const Color border = Color(0xFFE7E0D6);         // Warm Oat
  static const Color borderSubtle = Color(0xFFEFEAE2);   // Soft Linen
}
