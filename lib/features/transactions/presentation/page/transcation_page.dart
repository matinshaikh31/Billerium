import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/core/widgets/pagination.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:billing_software/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().initializeTransactionsPagination();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
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
  Widget _buildMobileLayout(TransactionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileHeader(),
          const SizedBox(height: 16),
          _buildMobileSearchFilter(),
          const SizedBox(height: 16),
          _buildMobileTransactionsList(state),
        ],
      ),
    );
  }

  // ===================== TABLET LAYOUT =====================
  Widget _buildTabletLayout(TransactionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildTransactionsTable(context, state),
        ],
      ),
    );
  }

  // ===================== DESKTOP LAYOUT =====================
  Widget _buildDesktopLayout(TransactionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildTransactionsTable(context, state),
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
      child: Row(
        children: [
          Icon(Icons.receipt_outlined, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Transactions',
              style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
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
          Icon(Icons.receipt_outlined, size: 30, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transactions', style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  'View all payment transactions',
                  style: AppTextStyles.headerSubheading,
                ),
              ],
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
          controller: context.read<TransactionCubit>().searchController,
          decoration: InputDecoration(
            hintText: 'Search by customer name or transaction ID...',
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
              context.read<TransactionCubit>().searchTransactions(value),
        ),
        const SizedBox(height: 12),
        _buildDateRangeFilter(),
      ],
    );
  }

  // ===================== DATE RANGE FILTER =====================
  Widget _buildDateRangeFilter() {
    return BlocBuilder<TransactionCubit, TransactionState>(
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
                  context.read<TransactionCubit>().filterByDateRange(value);
                }
              },
            ),
          ),
        );
      },
    );
  }

  // ===================== MOBILE TRANSACTIONS LIST =====================
  Widget _buildMobileTransactionsList(TransactionState state) {
    final displayTransactions = state.searchQuery.isNotEmpty
        ? state.searchedTransactions
        : state.filteredTransactions;

    if (state.isLoading && displayTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (displayTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: displayTransactions.length,
          itemBuilder: (context, index) {
            return _buildMobileTransactionCard(displayTransactions[index]);
          },
        ),
        if (state.totalPages > 1 && state.searchQuery.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DynamicPagination(
              currentPage: state.currentPage,
              totalPages: state.totalPages,
              onPageChanged: (page) {
                context.read<TransactionCubit>().fetchNextTransactionsPage(
                  page: page,
                );
              },
            ),
          ),
      ],
    );
  }

  // ===================== MOBILE TRANSACTION CARD =====================
  Widget _buildMobileTransactionCard(TransactionModel transaction) {
    final date = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(transaction.timestamp.toDate());

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
                      transaction.customerName,
                      style: AppTextStyles.tableRowPrimary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${transaction.id.substring(0, 8)}...',
                      style: AppTextStyles.tableRowSecondary.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPaymentModeBadge(transaction.mode),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: AppTextStyles.tableRowSecondary.copyWith(
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${transaction.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.tableRowBoldValue.copyWith(
                      color: AppColors.success,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Date & Time',
                    style: AppTextStyles.tableRowSecondary.copyWith(
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(date, style: AppTextStyles.tableRowSecondary),
                ],
              ),
            ],
          ),
          if (transaction.customerPhone != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  transaction.customerPhone!,
                  style: AppTextStyles.tableRowSecondary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ===================== TABLE SECTION =====================
  Widget _buildTransactionsTable(BuildContext context, TransactionState state) {
    final displayTransactions = state.searchQuery.isNotEmpty
        ? state.searchedTransactions
        : state.filteredTransactions;

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
          if (state.isLoading && displayTransactions.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (displayTransactions.isEmpty)
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
                  itemCount: displayTransactions.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionRow(displayTransactions[index]);
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
            controller: context.read<TransactionCubit>().searchController,
            decoration: InputDecoration(
              hintText: 'Search by customer name or transaction ID...',
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
                context.read<TransactionCubit>().searchTransactions(value),
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
            child: Text('Transaction ID', style: AppTextStyles.tabelHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('Customer', style: AppTextStyles.tabelHeader),
          ),
          Expanded(child: Text('Phone', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('Amount', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('Mode', style: AppTextStyles.tabelHeader)),
          Expanded(
            flex: 2,
            child: Text('Date & Time', style: AppTextStyles.tabelHeader),
          ),
        ],
      ),
    );
  }

  // ===================== TABLE ROWS =====================
  Widget _buildTransactionRow(TransactionModel transaction) {
    final date = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(transaction.timestamp.toDate());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              transaction.id.substring(0, 12) + '...',
              style: AppTextStyles.tableRowSecondary,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              transaction.customerName,
              style: AppTextStyles.tableRowPrimary,
            ),
          ),
          Expanded(
            child: Text(
              transaction.customerPhone ?? '-',
              style: AppTextStyles.tableRowSecondary,
            ),
          ),
          Expanded(
            child: Text(
              '₹${transaction.amount.toStringAsFixed(2)}',
              style: AppTextStyles.tableRowBoldValue.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
          Expanded(child: _buildPaymentModeBadge(transaction.mode)),
          Expanded(
            flex: 2,
            child: Text(date, style: AppTextStyles.tableRowSecondary),
          ),
        ],
      ),
    );
  }

  // ===================== PAYMENT MODE BADGE =====================
  Widget _buildPaymentModeBadge(String mode) {
    Color color;
    IconData icon;

    switch (mode) {
      case 'Cash':
        color = AppColors.success;
        icon = Icons.payments_outlined;
        break;
      case 'Card':
        color = AppColors.primary;
        icon = Icons.credit_card_outlined;
        break;
      case 'UPI':
        color = Colors.purple;
        icon = Icons.qr_code_2_outlined;
        break;
      case 'Bank Transfer':
        color = Colors.orange;
        icon = Icons.account_balance_outlined;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.attach_money_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            mode,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
            Icon(Icons.receipt_outlined, size: 64, color: AppColors.borderGrey),
            const SizedBox(height: 16),
            Text('No transactions found', style: AppTextStyles.tableRowPrimary),
          ],
        ),
      ),
    );
  }

  // ===================== PAGINATION =====================
  Widget _buildPagination(BuildContext context, TransactionState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: DynamicPagination(
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        onPageChanged: (page) {
          context.read<TransactionCubit>().fetchNextTransactionsPage(
            page: page,
          );
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
      context.read<TransactionCubit>().filterByDateRange(
        'Custom',
        startDate: picked.start,
        endDate: picked.end,
      );
    }
  }
}
