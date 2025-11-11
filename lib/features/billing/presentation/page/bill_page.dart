import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/core/widgets/pagination.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/presentation/cubit/bill_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BillCubit>().initializeBillsPagination();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillCubit, BillState>(
      builder: (context, state) {
        return ResponsiveCustomBuilder(
          mobileBuilder: (width) => _buildMobileLayout(state),
          tabletBuilder: (width) => _buildTabletLayout(state),
          desktopBuilder: (width) => _buildDesktopLayout(state),
        );
      },
    );
  }

  // ===================== MOBILE LAYOUT =====================
  Widget _buildMobileLayout(BillState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileHeader(),
          const SizedBox(height: 16),
          _buildMobileSearchFilter(),
          const SizedBox(height: 16),
          _buildMobileBillsList(state),
        ],
      ),
    );
  }

  // ===================== TABLET LAYOUT =====================
  Widget _buildTabletLayout(BillState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildBillsTable(context, state),
        ],
      ),
    );
  }

  // ===================== DESKTOP LAYOUT =====================
  Widget _buildDesktopLayout(BillState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildBillsTable(context, state),
        ],
      ),
    );
  }

  // ===================== MOBILE HEADER =====================
  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bills',
                  style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to create bill page
              },
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: Text(
                'Create Bill',
                style: GoogleFonts.inter(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== HEADER =====================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.secondary,
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined, size: 30, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bills', style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  'Manage customer bills and payments',
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to create bill page
            },
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: Text(
              'Create Bill',
              style: GoogleFonts.inter(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== MOBILE SEARCH + FILTER =====================
  Widget _buildMobileSearchFilter() {
    return Column(
      children: [
        TextField(
          controller: context.read<BillCubit>().searchController,
          decoration: InputDecoration(
            hintText: 'Search by customer name or phone...',
            hintStyle: AppTextStyles.hintText,
            prefixIcon: Icon(
              CupertinoIcons.search,
              size: 20,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) => context.read<BillCubit>().searchBills(value),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatusFilter()),
            const SizedBox(width: 12),
            Expanded(child: _buildDateRangeFilter()),
          ],
        ),
      ],
    );
  }

  // ===================== STATUS FILTER =====================
  Widget _buildStatusFilter() {
    return BlocBuilder<BillCubit, BillState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.statusFilter,
              hint: Text('All Status', style: AppTextStyles.tableRowRegular),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Status')),
                DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                DropdownMenuItem(
                  value: 'PartiallyPaid',
                  child: Text('Partially Paid'),
                ),
              ],
              onChanged: (value) =>
                  context.read<BillCubit>().filterByStatus(value),
            ),
          ),
        );
      },
    );
  }

  // ===================== DATE RANGE FILTER =====================
  Widget _buildDateRangeFilter() {
    return BlocBuilder<BillCubit, BillState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.dateRangeFilter,
              hint: Text('All Time', style: AppTextStyles.tableRowRegular),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Time')),
                DropdownMenuItem(value: 'LastWeek', child: Text('Last Week')),
                DropdownMenuItem(value: 'LastMonth', child: Text('Last Month')),
                DropdownMenuItem(
                  value: 'Last3Months',
                  child: Text('Last 3 Months'),
                ),
                DropdownMenuItem(value: 'Custom', child: Text('Custom')),
              ],
              onChanged: (value) {
                if (value == 'Custom') {
                  _showDateRangePicker(context);
                } else {
                  context.read<BillCubit>().filterByDateRange(value);
                }
              },
            ),
          ),
        );
      },
    );
  }

  // ===================== MOBILE BILLS LIST =====================
  Widget _buildMobileBillsList(BillState state) {
    final displayBills = state.searchQuery.isNotEmpty
        ? state.searchedBills
        : state.filteredBills;

    if (state.isLoading && displayBills.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (displayBills.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: displayBills.length,
          itemBuilder: (context, index) {
            return _buildMobileBillCard(displayBills[index]);
          },
        ),
        if (state.totalPages > 1 && state.searchQuery.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DynamicPagination(
              currentPage: state.currentPage,
              totalPages: state.totalPages,
              onPageChanged: (page) {
                context.read<BillCubit>().fetchNextBillsPage(page: page);
              },
            ),
          ),
      ],
    );
  }

  // ===================== MOBILE BILL CARD =====================
  Widget _buildMobileBillCard(BillModel bill) {
    final date = DateFormat('dd MMM yyyy').format(bill.createdAt.toDate());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.customerName ?? 'Walk-in Customer',
                      style: AppTextStyles.tableRowPrimary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bill.customerPhone ?? 'No phone',
                      style: AppTextStyles.tableRowSecondary,
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(bill.status),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoColumn('Date', date)),
              Expanded(
                child: _buildInfoColumn('Items', '${bill.items.length}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn(
                  'Total',
                  '₹${bill.finalAmount.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _buildInfoColumn(
                  'Paid',
                  '₹${bill.amountPaid.toStringAsFixed(0)}',
                  valueColor: AppColors.success,
                ),
              ),
              Expanded(
                child: _buildInfoColumn(
                  'Pending',
                  '₹${bill.pendingAmount.toStringAsFixed(0)}',
                  valueColor: bill.pendingAmount > 0
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showBillDetailsDialog(context, bill),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('View'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
              if (bill.status != 'Paid')
                TextButton.icon(
                  onPressed: () => _showAddPaymentDialog(context, bill),
                  icon: const Icon(Icons.payment_rounded, size: 16),
                  label: const Text('Pay'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tableRowSecondary.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.tableRowNormal.copyWith(color: valueColor),
        ),
      ],
    );
  }

  // ===================== TABLE SECTION =====================
  Widget _buildBillsTable(BuildContext context, BillState state) {
    final displayBills = state.searchQuery.isNotEmpty
        ? state.searchedBills
        : state.filteredBills;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          _buildTableSearchFilter(context),
          const SizedBox(height: 20),
          if (state.isLoading && displayBills.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (displayBills.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: [
                _buildTableHeaders(),
                Divider(height: 1, color: AppColors.divider),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.divider),
                  itemCount: displayBills.length,
                  itemBuilder: (context, index) {
                    return _buildBillRow(displayBills[index]);
                  },
                ),
                if (state.totalPages > 1 && state.searchQuery.isEmpty)
                  _buildPagination(context, state),
              ],
            ),
        ],
      ),
    );
  }

  // ===================== SEARCH + FILTER =====================
  Widget _buildTableSearchFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: context.read<BillCubit>().searchController,
            decoration: InputDecoration(
              hintText: 'Search by customer name or phone...',
              hintStyle: AppTextStyles.hintText,
              prefixIcon: Icon(
                CupertinoIcons.search,
                size: 20,
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderGrey),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) => context.read<BillCubit>().searchBills(value),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 180, child: _buildStatusFilter()),
        const SizedBox(width: 16),
        SizedBox(width: 180, child: _buildDateRangeFilter()),
      ],
    );
  }

  // ===================== TABLE HEADERS =====================
  Widget _buildTableHeaders() {
    return Container(
      color: AppColors.headerBackground,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text('Customer', style: AppTextStyles.tabelHeader),
          ),
          Expanded(child: Text('Phone', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('Date', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('Items', style: AppTextStyles.tabelHeader)),
          Expanded(
            child: Text('Final Amount', style: AppTextStyles.tabelHeader),
          ),
          Expanded(child: Text('Paid', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('Pending', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('Status', style: AppTextStyles.tabelHeader)),
          SizedBox(
            width: 100,
            child: Text('Actions', style: AppTextStyles.tabelHeader),
          ),
        ],
      ),
    );
  }

  // ===================== TABLE ROWS =====================
  Widget _buildBillRow(BillModel bill) {
    final date = DateFormat('dd MMM yyyy').format(bill.createdAt.toDate());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              bill.customerName ?? 'Walk-in',
              style: AppTextStyles.tableRowPrimary,
            ),
          ),
          Expanded(
            child: Text(
              bill.customerPhone ?? '-',
              style: AppTextStyles.tableRowSecondary,
            ),
          ),
          Expanded(child: Text(date, style: AppTextStyles.tableRowSecondary)),
          Expanded(
            child: Text(
              '${bill.items.length}',
              style: AppTextStyles.tableRowSecondary,
            ),
          ),
          Expanded(
            child: Text(
              '₹${bill.finalAmount.toStringAsFixed(0)}',
              style: AppTextStyles.tableRowBoldValue,
            ),
          ),
          Expanded(
            child: Text(
              '₹${bill.amountPaid.toStringAsFixed(0)}',
              style: AppTextStyles.tableRowNormal.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '₹${bill.pendingAmount.toStringAsFixed(0)}',
              style: AppTextStyles.tableRowNormal.copyWith(
                color: bill.pendingAmount > 0
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: _buildStatusBadge(bill.status)),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => _showBillDetailsDialog(context, bill),
                ),
                if (bill.status != 'Paid')
                  IconButton(
                    icon: Icon(
                      Icons.payment_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    onPressed: () => _showAddPaymentDialog(context, bill),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== STATUS BADGE =====================
  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'Paid':
        color = AppColors.success;
        text = 'Paid';
        break;
      case 'Unpaid':
        color = AppColors.error;
        text = 'Unpaid';
        break;
      default:
        color = AppColors.warning;
        text = 'Partial';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ===================== EMPTY STATE =====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.borderGrey,
            ),
            const SizedBox(height: 16),
            Text('No bills found', style: AppTextStyles.tableRowPrimary),
          ],
        ),
      ),
    );
  }

  // ===================== PAGINATION =====================
  Widget _buildPagination(BuildContext context, BillState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: DynamicPagination(
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        onPageChanged: (page) {
          context.read<BillCubit>().fetchNextBillsPage(page: page);
        },
      ),
    );
  }

  // ===================== DATE RANGE PICKER =====================
  void _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      context.read<BillCubit>().filterByDateRange(
        'Custom',
        startDate: picked.start,
        endDate: picked.end,
      );
    }
  }

  // ===================== BILL DETAILS DIALOG =====================
  void _showBillDetailsDialog(BuildContext context, BillModel bill) {
    final date = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(bill.createdAt.toDate());

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.secondary,
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bill Details',
                      style: AppTextStyles.customContainerTitle,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _detailRow('Customer', bill.customerName ?? 'Walk-in'),
                _detailRow('Phone', bill.customerPhone ?? '-'),
                _detailRow('Date', date),
                const SizedBox(height: 16),
                Text('Items', style: AppTextStyles.customContainerTitle),
                const SizedBox(height: 12),
                ...bill.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} x ${item.quantity}',
                            style: AppTextStyles.tableRowSecondary,
                          ),
                        ),
                        Text(
                          '₹${item.itemTotal.toStringAsFixed(2)}',
                          style: AppTextStyles.tableRowPrimary,
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                _detailRow('Subtotal', '₹${bill.subtotal.toStringAsFixed(2)}'),
                _detailRow(
                  'Discount',
                  '₹${bill.totalDiscount.toStringAsFixed(2)}',
                ),
                _detailRow('Tax', '₹${bill.totalTax.toStringAsFixed(2)}'),
                const Divider(height: 24),
                _detailRow(
                  'Final Amount',
                  '₹${bill.finalAmount.toStringAsFixed(2)}',
                  isTotal: true,
                ),
                _detailRow(
                  'Paid',
                  '₹${bill.amountPaid.toStringAsFixed(2)}',
                  valueColor: AppColors.success,
                ),
                _detailRow(
                  'Pending',
                  '₹${bill.pendingAmount.toStringAsFixed(2)}',
                  valueColor: bill.pendingAmount > 0
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.customContainerTitle
                : AppTextStyles.tableRowSecondary,
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.tableRowBoldValue
                : AppTextStyles.tableRowPrimary.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }

  // ===================== ADD PAYMENT DIALOG =====================
  void _showAddPaymentDialog(BuildContext context, BillModel bill) {
    final amountController = TextEditingController(
      text: bill.pendingAmount.toStringAsFixed(2),
    );
    String selectedMode = 'Cash';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Add Payment', style: AppTextStyles.dialogHeading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow(
              'Pending',
              '₹${bill.pendingAmount.toStringAsFixed(2)}',
              valueColor: AppColors.error,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: selectedMode,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: 'Payment Mode',
              ),
              items: ['Cash', 'Card', 'UPI', 'Bank Transfer']
                  .map(
                    (mode) => DropdownMenuItem(value: mode, child: Text(mode)),
                  )
                  .toList(),
              onChanged: (v) => selectedMode = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.tableRowSecondary),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final amt = double.tryParse(amountController.text);
              if (amt == null || amt <= 0 || amt > bill.pendingAmount) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Invalid amount')));
              } else {
                context.read<BillCubit>().addPaymentToBill(
                  bill.id,
                  amt,
                  selectedMode,
                );
                Navigator.pop(dialogContext);
              }
            },
            child: Text(
              'Add Payment',
              style: AppTextStyles.tableRowPrimary.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
