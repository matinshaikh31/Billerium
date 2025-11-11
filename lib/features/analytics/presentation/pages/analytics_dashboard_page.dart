import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:billing_software/features/analytics/presentation/widget/AnalyticsShimmer.dart';
import 'package:billing_software/features/analytics/presentation/widget/analytics_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsCubit>().initialize();
  }

  String _formatCurrency(double amount) => "₹${amount.toStringAsFixed(2)}";

  String _getMonthName(String monthKey) {
    try {
      final parts = monthKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return DateFormat('MMMM yyyy').format(DateTime(year, month));
    } catch (_) {
      return monthKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<AnalyticsCubit>().refresh(),
            color: AppColors.primary,
            child: ResponsiveCustomBuilder(
              mobileBuilder: (width) => _buildBody(context, state, true),
              desktopBuilder: (width) => _buildBody(context, state, false),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AnalyticsState state, bool isMobile) {
    return CustomScrollView(
      slivers: [
        _buildHeader(isMobile),
        SliverPadding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildFilterSection(context, state, isMobile),
              const SizedBox(height: 20),
              if (state.errorMessage != null)
                _buildErrorBanner(state.errorMessage!)
              else if (state.isLoading)
                const AnalyticsShimmer()
              else
                _buildAnalyticsContent(context, state, isMobile),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 100 : 130,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: isMobile ? 16 : 24, bottom: 12),
        title: Text(
          'Analytics Dashboard',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    AnalyticsState state,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Period',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  context,
                  'Monthly',
                  AnalyticsFilter.monthly,
                  state.currentFilter == AnalyticsFilter.monthly,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  context,
                  'Yearly',
                  AnalyticsFilter.yearly,
                  state.currentFilter == AnalyticsFilter.yearly,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPeriodDropdown(context, state),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String label,
    AnalyticsFilter filter,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => context.read<AnalyticsCubit>().changeFilter(filter),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.containerGreyColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown(BuildContext context, AnalyticsState state) {
    final isMonthly = state.currentFilter == AnalyticsFilter.monthly;
    final items = isMonthly ? state.availableMonths : state.availableYears;
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.containerGreyColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: DropdownButton<String>(
        value: items.contains(state.selectedPeriod)
            ? state.selectedPeriod
            : items.first,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        items: items.map((p) {
          return DropdownMenuItem(
            value: p,
            child: Text(isMonthly ? _getMonthName(p) : p),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            isMonthly
                ? context.read<AnalyticsCubit>().loadMonthlyData(value)
                : context.read<AnalyticsCubit>().loadYearlyData(value);
          }
        },
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    AnalyticsState state,
    bool isMobile,
  ) {
    final sales = state.salesData;
    if (sales == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Overview',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            AnalyticsCard(
              title: 'Total Sales',
              value: _formatCurrency(sales.totalSales),
              icon: Icons.trending_up,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
            AnalyticsCard(
              title: 'Total Paid',
              value: _formatCurrency(sales.totalPaid),
              icon: Icons.check_circle_outline,
              color: AppColors.today,
              backgroundColor: AppColors.today.withOpacity(0.1),
            ),
            AnalyticsCard(
              title: 'Pending',
              value: _formatCurrency(sales.totalPending),
              icon: Icons.pending_outlined,
              color: AppColors.overDue,
              backgroundColor: AppColors.overDue.withOpacity(0.1),
            ),
            AnalyticsCard(
              title: 'Total Bills',
              value: sales.totalBills.toString(),
              icon: Icons.receipt_long,
              color: AppColors.taskBtn,
              backgroundColor: AppColors.taskBtn.withOpacity(0.1),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Inventory Overview',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            AnalyticsCard(
              title: 'Products Sold',
              value: sales.totalProductsSold.toString(),
              icon: Icons.shopping_cart_outlined,
              color: AppColors.activityBtn,
              backgroundColor: AppColors.activityBtn.withOpacity(0.15),
            ),
            AnalyticsCard(
              title: 'Total Products',
              value: state.totalProducts.toString(),
              icon: Icons.inventory_2_outlined,
              color: AppColors.billBtn,
              backgroundColor: AppColors.billBtn.withOpacity(0.15),
            ),
            AnalyticsCard(
              title: 'Total Categories',
              value: state.totalCategories.toString(),
              icon: Icons.category_outlined,
              color: AppColors.documentBtn,
              backgroundColor: AppColors.documentBtn.withOpacity(0.15),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildPeriodInfo(state),
      ],
    );
  }

  Widget _buildPeriodInfo(AnalyticsState state) {
    final isMonthly = state.currentFilter == AnalyticsFilter.monthly;
    final periodText = isMonthly
        ? _getMonthName(state.selectedPeriod)
        : 'Year ${state.selectedPeriod}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Icon(
            isMonthly ? Icons.calendar_month : Icons.calendar_today,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Viewing Period:',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            periodText,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
