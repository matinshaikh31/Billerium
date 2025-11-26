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
    List<Widget> pageButtons = [];

    // Previous Button
    pageButtons.add(
      _navButton(
        label: 'Prev',
        enabled: currentPage > 1,
        onPressed: () => onPageChanged(currentPage - 1),
      ),
    );

    // Always show Page 1
    pageButtons.add(_pageButton(1, isCurrent: currentPage == 1));

    // Show ellipsis if gap between page 1 and start of middle range
    int start = currentPage - 1;
    int end = currentPage + 1;

    if (start > 2) {
      pageButtons.add(const _Ellipsis());
    }

    // Clamp middle range
    for (int i = start; i <= end; i++) {
      if (i > 1 && i < totalPages) {
        pageButtons.add(_pageButton(i, isCurrent: currentPage == i));
      }
    }

    // Show ellipsis if gap between end of middle and last page
    if (end < totalPages - 1) {
      pageButtons.add(const _Ellipsis());
    }

    // Always show last page
    bool enableLastPage = currentPage >= totalPages - 1;
    pageButtons.add(
      _pageButton(
        totalPages,
        isCurrent: currentPage == totalPages,
        enabled: enableLastPage,
      ),
    );

    // Next Button
    pageButtons.add(
      _navButton(
        label: 'Nex',
        enabled: currentPage < totalPages,
        onPressed: () => onPageChanged(currentPage + 1),
      ),
    );

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xffd5d9d9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: pageButtons,
        ),
      ),
    );
  }

  Widget _pageButton(int page, {bool isCurrent = false, bool enabled = true}) {
    return GestureDetector(
      onTap: page == currentPage
          ? null
          : enabled
          ? () => onPageChanged(page)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isCurrent ? Colors.black : Colors.transparent,
          ),
          color: Colors.white,
        ),
        child: Text(
          '$page',
          style: GoogleFonts.inter(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
            color: enabled ? const Color(0xff3E3E3E) : const Color(0xffCBCBCB),
          ),
        ),
      ),
    );
  }

  Widget _navButton({
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      icon: Icon(
        label == 'Nex'
            ? CupertinoIcons.chevron_right
            : CupertinoIcons.chevron_back,
        color: enabled ? const Color(0xff3E3E3E) : const Color(0xffCBCBCB),
      ),
      iconAlignment: label == 'Nex' ? IconAlignment.end : null,
      onPressed: enabled ? onPressed : null,
      style: ButtonStyle(
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(
          enabled ? const Color(0xff3E3E3E) : const Color(0xff929292),
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: enabled ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text("..."),
    );
  }
}
/* 
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
 */