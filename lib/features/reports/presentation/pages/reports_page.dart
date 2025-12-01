import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/features/reports/domain/entity/report_model.dart';
import 'package:billing_software/features/reports/presentation/cubit/report_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          return ResponsiveCustomBuilder(
            mobileBuilder: (width) => _buildBody(context, state, true),
            desktopBuilder: (width) => _buildBody(context, state, false),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReportState state, bool isMobile) {
    return CustomScrollView(
      slivers: [
        _buildHeader(isMobile),
        SliverPadding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildReportTypeSelector(context, state, isMobile),
              const SizedBox(height: 20),
              _buildDateRangeSection(context, state, isMobile),
              const SizedBox(height: 20),
              _buildGenerateButton(context, state),
              const SizedBox(height: 24),
              if (state.error != null) _buildErrorBanner(state.error!),
              if (state.isLoading) _buildLoadingIndicator(),
              if (state.hasGenerated && state.reportData != null)
                _buildReportContent(context, state, isMobile),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundColor,
      pinned: true,
      expandedHeight: isMobile ? 80 : 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: isMobile ? 16 : 24, bottom: 16),
        title: Text(
          'Reports',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector(
    BuildContext context,
    ReportState state,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Report Type', style: AppTextStyles.dialogHeading),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ReportType.values.map((type) {
            final isSelected = state.selectedType == type;
            return _buildTypeChip(context, type, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    ReportType type,
    bool isSelected,
  ) {
    IconData icon;
    switch (type) {
      case ReportType.sales:
        icon = Icons.trending_up;
        break;
      case ReportType.purchase:
        icon = Icons.shopping_bag_outlined;
        break;
      case ReportType.profit:
        icon = Icons.account_balance_wallet_outlined;
        break;
      case ReportType.inventory:
        icon = Icons.inventory_2_outlined;
        break;
      case ReportType.transaction:
        icon = Icons.receipt_long_outlined;
        break;
    }

    return InkWell(
      onTap: () => context.read<ReportCubit>().setReportType(type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.containerGreyColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _getTypeDisplayName(type),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(ReportType type) {
    switch (type) {
      case ReportType.sales:
        return 'Sales';
      case ReportType.purchase:
        return 'Purchase';
      case ReportType.profit:
        return 'Profit & Loss';
      case ReportType.inventory:
        return 'Inventory';
      case ReportType.transaction:
        return 'Transactions';
    }
  }

  Widget _buildDateRangeSection(
    BuildContext context,
    ReportState state,
    bool isMobile,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date Range', style: AppTextStyles.dialogHeading),
        const SizedBox(height: 12),
        // Quick presets
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetButton(context, 'Last 7 Days', () {
              context.read<ReportCubit>().setLast7Days();
            }),
            _buildPresetButton(context, 'Last 30 Days', () {
              context.read<ReportCubit>().setLast30Days();
            }),
            _buildPresetButton(context, 'This Month', () {
              context.read<ReportCubit>().setThisMonth();
            }),
            _buildPresetButton(context, 'Last Month', () {
              context.read<ReportCubit>().setLastMonth();
            }),
            _buildPresetButton(context, 'This Year', () {
              context.read<ReportCubit>().setThisYear();
            }),
          ],
        ),
        const SizedBox(height: 16),
        // Custom date pickers
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(context, 'Start Date', state.startDate, (
                date,
              ) {
                context.read<ReportCubit>().setDateRange(date, state.endDate);
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDatePicker(context, 'End Date', state.endDate, (
                date,
              ) {
                context.read<ReportCubit>().setDateRange(state.startDate, date);
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Selected: ${dateFormat.format(state.startDate)} - ${dateFormat.format(state.endDate)}',
          style: AppTextStyles.tableRowSecondary,
        ),
      ],
    );
  }

  Widget _buildPresetButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.containerGreyColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context, ReportState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state.isLoading
            ? null
            : () => context.read<ReportCubit>().generateReport(),
        icon: state.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.analytics_outlined),
        label: Text(state.isLoading ? 'Generating...' : 'Generate Report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildReportContent(
    BuildContext context,
    ReportState state,
    bool isMobile,
  ) {
    final data = state.reportData!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getTypeDisplayName(state.selectedType)} Report',
                style: AppTextStyles.dialogHeading,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                onPressed: () => context.read<ReportCubit>().generateReport(),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const Divider(height: 24),
          _buildReportDataByType(state.selectedType, data, isMobile),
        ],
      ),
    );
  }

  Widget _buildReportDataByType(
    ReportType type,
    Map<String, dynamic> data,
    bool isMobile,
  ) {
    switch (type) {
      case ReportType.sales:
        return _buildSalesReportData(data, isMobile);
      case ReportType.purchase:
        return _buildPurchaseReportData(data, isMobile);
      case ReportType.profit:
        return _buildProfitReportData(data, isMobile);
      case ReportType.inventory:
        return _buildInventoryReportData(data, isMobile);
      case ReportType.transaction:
        return _buildTransactionReportData(data, isMobile);
    }
  }

  Widget _buildSalesReportData(Map<String, dynamic> data, bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Total Sales',
          '₹${(data['totalSales'] ?? 0).toStringAsFixed(2)}',
          Icons.trending_up,
          AppColors.primary,
        ),
        _buildStatCard(
          'Total Paid',
          '₹${(data['totalPaid'] ?? 0).toStringAsFixed(2)}',
          Icons.check_circle,
          AppColors.success,
        ),
        _buildStatCard(
          'Pending',
          '₹${(data['totalPending'] ?? 0).toStringAsFixed(2)}',
          Icons.pending,
          AppColors.warning,
        ),
        _buildStatCard(
          'Total Bills',
          '${data['totalBills'] ?? 0}',
          Icons.receipt_long,
          AppColors.taskBtn,
        ),
        _buildStatCard(
          'Products Sold',
          '${data['totalProductsSold'] ?? 0}',
          Icons.shopping_cart,
          AppColors.activityBtn,
        ),
      ],
    );
  }

  Widget _buildPurchaseReportData(Map<String, dynamic> data, bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Total Purchases',
          '₹${(data['totalPurchaseAmount'] ?? 0).toStringAsFixed(2)}',
          Icons.shopping_bag,
          AppColors.error,
        ),
        _buildStatCard(
          'Items Purchased',
          '${data['totalItemsPurchased'] ?? 0}',
          Icons.add_shopping_cart,
          AppColors.warning,
        ),
        _buildStatCard(
          'Total Orders',
          '${data['totalPurchases'] ?? 0}',
          Icons.receipt,
          AppColors.taskBtn,
        ),
      ],
    );
  }

  Widget _buildProfitReportData(Map<String, dynamic> data, bool isMobile) {
    final grossProfit = (data['grossProfit'] ?? 0).toDouble();
    final profitMargin = (data['profitMargin'] ?? 0).toDouble();
    final isProfit = grossProfit >= 0;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Total Sales',
          '₹${(data['totalSales'] ?? 0).toStringAsFixed(2)}',
          Icons.trending_up,
          AppColors.primary,
        ),
        _buildStatCard(
          'Total Purchases',
          '₹${(data['totalPurchases'] ?? 0).toStringAsFixed(2)}',
          Icons.shopping_bag,
          AppColors.error,
        ),
        _buildStatCard(
          'Gross Profit',
          '₹${grossProfit.toStringAsFixed(2)}',
          isProfit ? Icons.arrow_upward : Icons.arrow_downward,
          isProfit ? AppColors.success : AppColors.error,
        ),
        _buildStatCard(
          'Profit Margin',
          '${profitMargin.toStringAsFixed(1)}%',
          Icons.percent,
          isProfit ? AppColors.success : AppColors.error,
        ),
      ],
    );
  }

  Widget _buildInventoryReportData(Map<String, dynamic> data, bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Total Products',
          '${data['totalProducts'] ?? 0}',
          Icons.inventory_2,
          AppColors.primary,
        ),
        _buildStatCard(
          'Low Stock',
          '${data['lowStockProducts'] ?? 0}',
          Icons.warning_amber,
          AppColors.warning,
        ),
        _buildStatCard(
          'Out of Stock',
          '${data['outOfStockProducts'] ?? 0}',
          Icons.error_outline,
          AppColors.error,
        ),
        _buildStatCard(
          'Inventory Value',
          '₹${(data['totalInventoryValue'] ?? 0).toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildTransactionReportData(Map<String, dynamic> data, bool isMobile) {
    final modeBreakdown = data['modeBreakdown'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              'Total Amount',
              '₹${(data['totalAmount'] ?? 0).toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              AppColors.primary,
            ),
            _buildStatCard(
              'Total Transactions',
              '${data['totalTransactions'] ?? 0}',
              Icons.receipt_long,
              AppColors.taskBtn,
            ),
          ],
        ),
        if (modeBreakdown.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Payment Mode Breakdown', style: AppTextStyles.tableRowPrimary),
          const SizedBox(height: 12),
          ...modeBreakdown.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: AppTextStyles.tableRowSecondary),
                  Text(
                    '₹${(e.value as num).toStringAsFixed(2)}',
                    style: AppTextStyles.tableRowPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
