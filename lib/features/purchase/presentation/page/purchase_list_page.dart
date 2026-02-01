import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/core/widgets/pagination.dart';
import 'package:billing_software/features/purchase/domain/entity/purchase_model.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_cubit.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_state.dart';
import 'package:billing_software/features/purchase/presentation/page/create_purchase_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PurchaseCubit>().initializePurchasesPagination();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseCubit, PurchaseState>(
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
  Widget _buildMobileLayout(PurchaseState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileHeader(),
          const SizedBox(height: 16),
          _buildMobileSearchFilter(),
          const SizedBox(height: 16),
          _buildMobilePurchasesList(state),
        ],
      ),
    );
  }

  // ===================== TABLET LAYOUT =====================
  Widget _buildTabletLayout(PurchaseState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildPurchasesTable(context, state),
        ],
      ),
    );
  }

  // ===================== DESKTOP LAYOUT =====================
  Widget _buildDesktopLayout(PurchaseState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildPurchasesTable(context, state),
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
                Icons.shopping_bag_outlined,
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Purchases',
                  style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreatePurchaseDialog(context),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: Text(
                'New Purchase',
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
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border(bottom: BorderSide(color: AppColors.blueGreyBorder)),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 30, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Purchases', style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  'Track your inventory purchases',
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreatePurchaseDialog(context),
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: Text(
              'New Purchase',
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
          controller: context.read<PurchaseCubit>().searchController,
          decoration: InputDecoration(
            hintText: 'Search by supplier or purchase no...',
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
          onChanged: (value) =>
              context.read<PurchaseCubit>().searchPurchases(value),
        ),
        const SizedBox(height: 12),
        _buildDateRangeFilter(),
      ],
    );
  }

  // ===================== DATE RANGE FILTER =====================
  Widget _buildDateRangeFilter() {
    return BlocBuilder<PurchaseCubit, PurchaseState>(
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
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: null, child: Text('All Time')),
                DropdownMenuItem(value: 'LastWeek', child: Text('Last Week')),
                DropdownMenuItem(value: 'LastMonth', child: Text('Last Month')),
                DropdownMenuItem(
                  value: 'Last3Months',
                  child: Text('Last 3 Months'),
                ),
                DropdownMenuItem(value: 'Custom', child: Text('Custom Range')),
              ],
              onChanged: (value) {
                if (value == 'Custom') {
                  _showDateRangePicker(context);
                } else {
                  context.read<PurchaseCubit>().filterByDateRange(value);
                }
              },
            ),
          ),
        );
      },
    );
  }

  // ===================== DATE RANGE PICKER =====================
  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.secondary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      if (!mounted) return;
      this.context.read<PurchaseCubit>().filterByDateRange(
        'Custom',
        startDate: picked.start,
        endDate: picked.end,
      );
    }
  }

  // ===================== PURCHASES TABLE =====================
  Widget _buildPurchasesTable(BuildContext context, PurchaseState state) {
    final displayPurchases = state.searchQuery.isNotEmpty
        ? state.searchedPurchases
        : state.filteredPurchases;

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
          if (state.isLoading && displayPurchases.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (displayPurchases.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: [
                _buildTableHeaders(),
                Divider(height: 1, color: AppColors.divider),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: AppColors.divider),
                  itemCount: displayPurchases.length,
                  itemBuilder: (context, index) {
                    return _buildPurchaseRow(displayPurchases[index]);
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

  // ===================== TABLE SEARCH + FILTER =====================
  Widget _buildTableSearchFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: context.read<PurchaseCubit>().searchController,
            decoration: InputDecoration(
              hintText: 'Search by supplier or purchase no...',
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
            onChanged: (value) =>
                context.read<PurchaseCubit>().searchPurchases(value),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 200, child: _buildDateRangeFilter()),
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
            child: Text('Purchase No', style: AppTextStyles.tabelHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('Supplier', style: AppTextStyles.tabelHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('Date', style: AppTextStyles.tabelHeader),
          ),
          Expanded(child: Text('Items', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('Amount', style: AppTextStyles.tabelHeader)),
          SizedBox(
            width: 100,
            child: Text('Actions', style: AppTextStyles.tabelHeader),
          ),
        ],
      ),
    );
  }

  // ===================== TABLE ROWS =====================
  Widget _buildPurchaseRow(PurchaseModel purchase) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              purchase.purchaseNo,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              purchase.supplierName ?? 'N/A',
              style: AppTextStyles.tableRowPrimary,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              dateFormat.format(purchase.createdAt.toDate()),
              style: AppTextStyles.tableRowSecondary,
            ),
          ),
          Expanded(
            child: Text(
              '${purchase.items.length}',
              style: AppTextStyles.tableRowNormal,
            ),
          ),
          Expanded(
            child: Text(
              '₹${purchase.finalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.tableRowBoldValue.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  onPressed: () =>
                      _showPurchaseDetailsDialog(context, purchase),
                  tooltip: 'View Details',
                ),
                // IconButton(
                //   icon: Icon(
                //     Icons.delete_outline,
                //     size: 18,
                //     color: AppColors.warning,
                //   ),
                //   onPressed: () => _showDeleteDialog(context, purchase),
                //   tooltip: 'Delete',
                // ),
              ],
            ),
          ),
        ],
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
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.borderGrey,
            ),
            const SizedBox(height: 16),
            Text('No purchases found', style: AppTextStyles.tableRowPrimary),
          ],
        ),
      ),
    );
  }

  // ===================== PAGINATION =====================
  Widget _buildPagination(BuildContext context, PurchaseState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: DynamicPagination(
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        onPageChanged: (page) {
          context.read<PurchaseCubit>().fetchNextPurchasesPage(page: page);
        },
      ),
    );
  }

  // ===================== MOBILE PURCHASES LIST =====================
  Widget _buildMobilePurchasesList(PurchaseState state) {
    final displayPurchases = state.searchQuery.isNotEmpty
        ? state.searchedPurchases
        : state.filteredPurchases;

    if (state.isLoading && displayPurchases.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (displayPurchases.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayPurchases.length,
          itemBuilder: (context, index) {
            final purchase = displayPurchases[index];
            return _buildMobilePurchaseCard(purchase);
          },
        ),
        if (state.totalPages > 1 && state.searchQuery.isEmpty)
          _buildPagination(context, state),
      ],
    );
  }

  // ===================== MOBILE PURCHASE CARD =====================
  Widget _buildMobilePurchaseCard(PurchaseModel purchase) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                purchase.purchaseNo,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '₹${purchase.finalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (purchase.supplierName != null)
            Text(
              'Supplier: ${purchase.supplierName}',
              style: AppTextStyles.tableRowSecondary,
            ),
          Text(
            'Date: ${dateFormat.format(purchase.createdAt.toDate())}',
            style: AppTextStyles.tableRowSecondary,
          ),
          Text(
            'Items: ${purchase.items.length}',
            style: AppTextStyles.tableRowSecondary,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showPurchaseDetailsDialog(context, purchase),
                icon: Icon(Icons.visibility_outlined, size: 16),
                label: Text('View'),
              ),
              TextButton.icon(
                onPressed: () => _showDeleteDialog(context, purchase),
                icon: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: AppColors.warning,
                ),
                label: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.warning),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== SHOW CREATE PURCHASE DIALOG =====================
  void _showCreatePurchaseDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePurchasePage()),
    );
  }

  // ===================== SHOW PURCHASE DETAILS DIALOG =====================
  void _showPurchaseDetailsDialog(
    BuildContext context,
    PurchaseModel purchase,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Purchase Details',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Purchase No', purchase.purchaseNo),
              _buildDetailRow('Supplier', purchase.supplierName ?? 'N/A'),
              _buildDetailRow('Phone', purchase.supplierPhone ?? 'N/A'),
              if (purchase.supplierGstNumber != null &&
                  purchase.supplierGstNumber!.isNotEmpty)
                _buildDetailRow('GST Number', purchase.supplierGstNumber!),
              _buildDetailRow(
                'Date',
                dateFormat.format(purchase.createdAt.toDate()),
              ),
              const SizedBox(height: 16),
              Text(
                'Items',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: purchase.items.length,
                  itemBuilder: (context, index) {
                    final item = purchase.items[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${item.quantity} x ₹${item.purchasePrice.toStringAsFixed(2)}',
                                  style: AppTextStyles.tableRowSecondary,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${item.total.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              _buildDetailRow(
                'Subtotal',
                '₹${purchase.subtotal.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Tax',
                '₹${purchase.totalTax.toStringAsFixed(2)}',
              ),
              if (purchase.otherExpense > 0)
                _buildDetailRow(
                  'Other Expenses',
                  '₹${purchase.otherExpense.toStringAsFixed(2)}',
                ),
              _buildDetailRow(
                'Total Amount',
                '₹${purchase.finalAmount.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== DETAIL ROW =====================
  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.tableRowSecondary),
          Text(
            value,
            style: isBold
                ? GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)
                : AppTextStyles.tableRowPrimary,
          ),
        ],
      ),
    );
  }

  // ===================== SHOW DELETE DIALOG =====================
  void _showDeleteDialog(BuildContext context, PurchaseModel purchase) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Purchase'),
        content: Text(
          'Are you sure you want to delete purchase "${purchase.purchaseNo}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PurchaseCubit>().deletePurchase(purchase.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
