// import 'package:flutter/material.dart';

// class AppColors {
//   // 🌿 Brand Colors (Balanced contrast for logo visibility)
//   static const Color primary = Color(0xFF124C5A); // Core Teal (Logo Color)
//   static const Color primaryDark = Color(
//     0xFF0D3742,
//   ); // Darker shade (for hover or sidebar)
//   static const Color primaryLight = Color(
//     0xFF1E5E6C,
//   ); // Slightly lighter teal for contrast
//   static const Color secondary = Color(
//     0xFFFDFBF8,
//   ); // Light warm background (enhances teal contrast)
//   static const Color backgroundColor = Color(
//     0xFFF7F6F4,
//   ); // Softer app background for sections
//   static const Color containerGreyColor = Color(
//     0xFFFAFAFA,
//   ); // Clean light cards/containers

//   // 💠 Accents & Highlights
//   static const Color accent = Color(
//     0xFF0E3943,
//   ); // Deep Teal accent for emphasis
//   static const Color highlight = Color(
//     0xFFD8E6E3,
//   ); // Light mint highlight for hover/selection

//   // 🧱 Neutral / Text / Border Colors
//   static const Color textPrimary = Color(
//     0xFF0E1F21,
//   ); // Deep charcoal (best contrast on light)
//   static const Color textSecondary = Color(
//     0xFF446064,
//   ); // Muted gray-teal for secondary labels
//   static const Color textLight = Color(0xFFFAFAFA); // For dark backgrounds
//   static const Color borderGrey = Color(0xFFE1E5EA); // Light borders
//   static const Color divider = Color(0xFFDCE1E4); // Subtle divider

//   // 🟩 Buttons / Actions (Brand variations)
//   static const Color taskBtn = Color(
//     0xFF1A6C79,
//   ); // Balanced teal for task actions
//   static const Color billBtn = Color(0xFF269C88); // Slightly greenish teal
//   static const Color documentBtn = Color(
//     0xFF36B7A1,
//   ); // Soft mint tone for documents
//   static const Color activityBtn = Color(
//     0xFF6EC3B6,
//   ); // Pastel mint for lighter actions

//   // ⚠️ Status / Alerts
//   static const Color success = Color(0xFF47A76A); // Success green
//   static const Color warning = Color(0xFFE67E22); // Orange warning
//   static const Color error = Color(0xFFE74C3C); // Red alert
//   static const Color info = Color(0xFF2F80ED); // Informational blue

//   // 🧾 Utility / Shadows / Lines
//   static const Color blueGreyBorder = Color(0xFFD0D7DE);
//   static const Color shadow = Color(0x1A000000); // Light transparent shadow
//   static const Color surface = Color(
//     0xFFFFFFFF,
//   ); // White surface for elevated cards

//   // 🌙 Sidebar / Header Backgrounds
//   static const Color sidebarBackground = Color(
//     0xFFEEF2F2,
//   ); // Light greyish background (keeps logo visible)
//   static const Color headerBackground = Color(0xFFE9F1F0);
//   // Light muted teal tint for header sections

//   // Category Accent Colors
//   static const Color categoryAccent = Color(
//     0xFF1A6C79,
//   ); // for icons, teal-based
//   static const Color categoryAccentLight = Color(0xFFD8E6E3); // for bg tints

//   static const Color categoryCard = Color(0xFFFBFAF8); // subtle card background
//   // reused for section header rows

//   // 💳 Billing Section Colors
//   static const Color billingCard = Color(0xFFFBFAF8);
//   static const Color billingAccent = Color(0xFF1A6C79); // deep teal
//   static const Color billingAccentLight = Color(0xFFD9E6E3);
//   static const Color warningSoft = Color(0xFFFFF4E5);
//   static const Color successSoft = Color(0xFFE7F7E7);
//   // Bills Theme Extensions
//   static const Color tableSurface = Color(0xFFFCFBF9); // light table background
//   static const Color cardShadow = Color(0x11000000);

//   static const Color errorSoft = Color(0xFFFBEAEA);
// }
import 'package:flutter/material.dart';

class AppColors {
  // 🌿 Brand Colors (Balanced contrast for logo visibility)
  static const Color primary = Color(0xFF124C5A); // Core Teal (Logo Color)
  static const Color primaryDark = Color(
    0xFF0D3742,
  ); // Darker shade (for hover or sidebar)
  static const Color primaryLight = Color(
    0xFF1E5E6C,
  ); // Slightly lighter teal for contrast
  static const Color secondary = Color(
    0xFFFDFBF8,
  ); // Light warm background (enhances teal contrast)
  static const Color backgroundColor = Color(
    0xFFF7F6F4,
  ); // Softer app background for sections
  static const Color containerGreyColor = Color(
    0xFFFAFAFA,
  ); // Clean light cards/containers

  // 💠 Accents & Highlights
  static const Color accent = Color(
    0xFF0E3943,
  ); // Deep Teal accent for emphasis
  static const Color highlight = Color(
    0xFFD8E6E3,
  ); // Light mint highlight for hover/selection

  // 🧱 Neutral / Text / Border Colors
  static const Color textPrimary = Color(
    0xFF0E1F21,
  ); // Deep charcoal (best contrast on light)
  static const Color textSecondary = Color(
    0xFF446064,
  ); // Muted gray-teal for secondary labels
  static const Color textLight = Color(0xFFFAFAFA); // For dark backgrounds
  static const Color borderGrey = Color(0xFFE1E5EA); // Light borders
  static const Color divider = Color(0xFFDCE1E4); // Subtle divider

  // 🟩 Buttons / Actions (Brand variations)
  static const Color taskBtn = Color(
    0xFF1A6C79,
  ); // Balanced teal for task actions
  static const Color billBtn = Color(0xFF269C88); // Slightly greenish teal
  static const Color documentBtn = Color(
    0xFF36B7A1,
  ); // Soft mint tone for documents
  static const Color activityBtn = Color(
    0xFF6EC3B6,
  ); // Pastel mint for lighter actions

  // ⚠️ Status / Alerts
  static const Color success = Color(0xFF47A76A); // Success green
  static const Color warning = Color(0xFFE67E22); // Orange warning
  static const Color error = Color(0xFFE74C3C); // Red alert
  static const Color info = Color(0xFF2F80ED); // Informational blue

  // 🧾 Utility / Shadows / Lines
  static const Color blueGreyBorder = Color(0xFFD0D7DE);
  static const Color shadow = Color(0x1A000000); // Light transparent shadow
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // White surface for elevated cards

  // 🌙 Sidebar / Header Backgrounds
  static const Color sidebarBackground = Color(
    0xFFEEF2F2,
  ); // Light greyish background (keeps logo visible)
  static const Color headerBackground = Color(
    0xFFE9F1F0,
  ); // Light muted teal tint for header sections

  // Category Accent Colors
  static const Color categoryAccent = Color(
    0xFF1A6C79,
  ); // for icons, teal-based
  static const Color categoryAccentLight = Color(0xFFD8E6E3); // for bg tints
  static const Color categoryCard = Color(0xFFFBFAF8); // subtle card background

  // 💳 Billing Section Colors
  static const Color billingCard = Color(0xFFFBFAF8);
  static const Color billingAccent = Color(0xFF1A6C79); // deep teal
  static const Color billingAccentLight = Color(0xFFD9E6E3);
  static const Color warningSoft = Color(0xFFFFF4E5);
  static const Color successSoft = Color(0xFFE7F7E7);
  static const Color tableSurface = Color(0xFFFCFBF9); // light table background
  static const Color cardShadow = Color(0x11000000);
  static const Color errorSoft = Color(0xFFFBEAEA);

  // 🆕 Added Aliases & Extended Colors for Compatibility

  // ✅ Background alias (for code that uses AppColors.background)
  static const Color background = backgroundColor;

  // ✅ Text Black alias (used in older widgets)
  static const Color textBlackColor = Color(0xFF0D1B1E);

  // ✅ Status Aliases (for older pages like analytics)
  static const Color today = success; // alias to success
  static const Color overDue = warning; // alias to warning

  // ✅ Info soft variant (for shaded info boxes)
  static const Color infoSoft = Color(0x1F2F80ED); // transparent info blue

  // ✅ Additional semantic variants for flexibility
  static const Color primaryVariant = primaryDark;
  static const Color neutralBorder = borderGrey;
}
