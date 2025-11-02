// core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final headerHeading = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );
  static final headerSubheading = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.slateGray,
  );
  static final tabelHeader = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.slateGray,
  );
  static final dialogHeading = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  static final dialogSubheading = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slateGray,
  );
  static final textFieldTitle = GoogleFonts.inter(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: AppColors.primary,
  );

  //CustomConatiner
  static final customContainerTitle = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  static final customContainerSubTitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slateGray,
  );

  // Navigation
  static final navBarItems = GoogleFonts.inter(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  //stat cards styles
  static final statCardLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slateGray,
  );
  static final statCardValue = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  static final hintText = GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.slateGray,
    fontWeight: FontWeight.w400,
  );

  // ============ TABLE STYLES ============

  // Table Row Primary Text (Bold text like names, IDs)
  static final tableRowPrimary = GoogleFonts.inter(
    fontWeight: FontWeight.bold,
    fontSize: 15,
    color: AppColors.textBlackColor,
  );

  // Table Row Secondary Text (Smaller, gray text)
  static final tableRowSecondary = GoogleFonts.inter(
    fontSize: 13.5,
    color: AppColors.slateGray,
  );

  // Table Row Normal Text (Regular data)
  static final tableRowNormal = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textBlackColor,
    fontWeight: FontWeight.w500,
  );

  // Table Row Bold Numbers/Values
  static final tableRowBoldValue = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.textBlackColor,
  );

  // Table Row Regular Text
  static final tableRowRegular = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textBlackColor,
  );

  // Table Row Date Text
  static final tableRowDate = GoogleFonts.inter(
    fontSize: 15,
    color: AppColors.textBlackColor,
  );
}
