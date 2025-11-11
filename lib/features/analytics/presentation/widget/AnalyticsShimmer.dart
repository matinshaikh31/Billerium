import 'package:billing_software/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class AnalyticsShimmer extends StatelessWidget {
  const AnalyticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(4, (_) => _buildCardShimmer()),
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(width: 36, height: 36),
          const SizedBox(height: 12),
          _shimmerBox(width: 100, height: 14),
          const SizedBox(height: 8),
          _shimmerBox(width: 120, height: 24),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.containerGreyColor,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
