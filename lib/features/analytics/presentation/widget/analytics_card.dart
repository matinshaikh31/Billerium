import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color; // icon color
  final Color backgroundColor; // light tint bg

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Container(
      width: isMobile ? double.infinity : 260,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: AppColors.categoryCard, // SAME AS CATEGORY CARD
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON BOX
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isMobile ? 20 : 22),
          ),

          SizedBox(height: isMobile ? 10 : 14),

          // TITLE
          Text(
            title,
            style: AppTextStyles.tableRowSecondary.copyWith(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          // VALUE
          Text(
            value,
            style: AppTextStyles.tableRowBoldValue.copyWith(
              fontSize: isMobile ? 20 : 22,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
