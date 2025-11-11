// core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // 🌟 Headers
  static final headerHeading = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.primary, // Dark teal instead of black
  );

  static final headerSubheading = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, // Muted teal-gray
  );

  // 📊 Table Headers
  static final tabelHeader = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, // Strong readable teal-black
  );

  // 🧾 Dialogs
  static final dialogHeading = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary, // Accent teal
  );

  static final dialogSubheading = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, // Muted text
  );

  // 🧍‍♂️ Form Field Titles
  static final textFieldTitle = GoogleFonts.inter(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: AppColors.primary,
  );

  // 🧱 Custom Container
  static final customContainerTitle = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static final customContainerSubTitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // 🧭 Navigation Bar
  static final navBarItems = GoogleFonts.inter(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  // 📈 Stat Cards
  static final statCardLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final statCardValue = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static final hintText = GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  // ============ 📋 TABLE STYLES ============

  static final tableRowPrimary = GoogleFonts.inter(
    fontWeight: FontWeight.bold,
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static final tableRowSecondary = GoogleFonts.inter(
    fontSize: 13.5,
    color: AppColors.textSecondary,
  );

  static final tableRowNormal = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static final tableRowBoldValue = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.primary,
  );

  static final tableRowRegular = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static final tableRowDate = GoogleFonts.inter(
    fontSize: 15,
    color: AppColors.textSecondary,
  );
}
