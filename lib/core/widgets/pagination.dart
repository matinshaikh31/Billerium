import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DynamicPagination extends StatelessWidget {
  const DynamicPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return ResponsiveCustomBuilder(
      mobileBuilder: (width) => _buildPagination(context, isMobile: true),
      desktopBuilder: (width) => _buildPagination(context, isMobile: false),
    );
  }

  Widget _buildPagination(BuildContext context, {required bool isMobile}) {
    final List<Widget> pageButtons = [];

    // Previous Button
    pageButtons.add(
      _navButton(
        label: 'Prev',
        enabled: currentPage > 1,
        onPressed: () => onPageChanged(currentPage - 1),
        isMobile: isMobile,
      ),
    );

    // Always show Page 1
    pageButtons.add(
      _pageButton(1, isCurrent: currentPage == 1, isMobile: isMobile),
    );

    // Middle range
    int start = currentPage - 1;
    int end = currentPage + 1;

    if (start > 2) {
      pageButtons.add(const _Ellipsis());
    }

    for (int i = start; i <= end; i++) {
      if (i > 1 && i < totalPages) {
        pageButtons.add(
          _pageButton(i, isCurrent: currentPage == i, isMobile: isMobile),
        );
      }
    }

    if (end < totalPages - 1) {
      pageButtons.add(const _Ellipsis());
    }

    // Last page
    pageButtons.add(
      _pageButton(
        totalPages,
        isCurrent: currentPage == totalPages,
        isMobile: isMobile,
      ),
    );

    // Next Button
    pageButtons.add(
      _navButton(
        label: 'Next',
        enabled: currentPage < totalPages,
        onPressed: () => onPageChanged(currentPage + 1),
        isMobile: isMobile,
      ),
    );

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 4 : 8,
          vertical: isMobile ? 6 : 10,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(mainAxisSize: MainAxisSize.min, children: pageButtons),
        ),
      ),
    );
  }

  // ========================= Page Button =========================

  Widget _pageButton(
    int page, {
    bool isCurrent = false,
    bool isMobile = false,
  }) {
    return GestureDetector(
      onTap: page == currentPage ? null : () => onPageChanged(page),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 14,
          vertical: isMobile ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.primary.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent ? AppColors.primary : AppColors.borderGrey,
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Text(
          '$page',
          style: GoogleFonts.inter(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            fontSize: isMobile ? 13 : 14,
            color: isCurrent ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ========================= Nav Button (Prev / Next) =========================

  Widget _navButton({
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    final isNext = label == 'Next';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
      child: TextButton.icon(
        icon: Icon(
          isNext ? CupertinoIcons.chevron_right : CupertinoIcons.chevron_back,
          size: isMobile ? 16 : 18,
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 13 : 14,
            letterSpacing: 0.3,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 6 : 12,
            vertical: isMobile ? 6 : 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: enabled
                  ? AppColors.borderGrey
                  : AppColors.borderGrey.withOpacity(0.5),
            ),
          ),
          backgroundColor: enabled
              ? AppColors.secondary
              : AppColors.secondary.withOpacity(0.7),
        ),
      ),
    );
  }
}

// ========================= Ellipsis Widget =========================

class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        "...",
        style: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
