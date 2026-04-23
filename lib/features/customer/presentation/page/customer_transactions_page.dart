import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:billing_software/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomerTransactionsPage extends StatefulWidget {
  const CustomerTransactionsPage({super.key});

  @override
  State<CustomerTransactionsPage> createState() =>
      _CustomerTransactionsPageState();
}

class _CustomerTransactionsPageState extends State<CustomerTransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().initializeTransactionsPagination();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            Expanded(child: _buildTransactionsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_outlined,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer Transactions', style: AppTextStyles.headerHeading),
              const SizedBox(height: 4),
              Text(
                'View all customer transactions',
                style: AppTextStyles.headerSubheading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get transactions from the state (use filtered or searched based on query)
        final allTransactions = state.searchQuery.isNotEmpty
            ? state.searchedTransactions
            : state.filteredTransactions;

        // Filter only customer transactions (where customerId is not null)
        final customerTransactions = allTransactions
            .where((transaction) => transaction.customerId != null)
            .toList();

        if (customerTransactions.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: customerTransactions.length,
          itemBuilder: (context, index) {
            final transaction = customerTransactions[index];
            return _buildTransactionCard(transaction);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final date = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(transaction.timestamp.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
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
                    'Bill No: ${transaction.billNo}',
                    style: AppTextStyles.tableRowSecondary,
                  ),
                  Text(
                    date,
                    style: AppTextStyles.tableRowSecondary.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${transaction.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No customer transactions found',
            style: AppTextStyles.customContainerTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
