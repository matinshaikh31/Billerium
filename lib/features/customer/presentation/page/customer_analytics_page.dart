import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:billing_software/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billing_software/features/customer/presentation/cubit/customer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerAnalyticsPage extends StatefulWidget {
  const CustomerAnalyticsPage({super.key});

  @override
  State<CustomerAnalyticsPage> createState() => _CustomerAnalyticsPageState();
}

class _CustomerAnalyticsPageState extends State<CustomerAnalyticsPage> {
  String selectedPeriod = 'Monthly'; // 'Monthly' or 'Yearly'

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().initializePagination();
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
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            Expanded(child: _buildAnalyticsList()),
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
            Icons.analytics_outlined,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer Analytics', style: AppTextStyles.headerHeading),
              const SizedBox(height: 4),
              Text(
                'View monthly and yearly customer performance',
                style: AppTextStyles.headerSubheading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodButton('Monthly'),
        const SizedBox(width: 12),
        _buildPeriodButton('Yearly'),
      ],
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = selectedPeriod == period;
    return ElevatedButton(
      onPressed: () {
        setState(() => selectedPeriod = period);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
        foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
          ),
        ),
      ),
      child: Text(period),
    );
  }

  Widget _buildAnalyticsList() {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state.isLoading && state.customers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.customers.isEmpty) {
          return _buildEmptyState();
        }

        // Sort customers by total purchases (highest first)
        final sortedCustomers = List.from(state.customers)
          ..sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));

        return ListView.builder(
          itemCount: sortedCustomers.length,
          itemBuilder: (context, index) {
            final customer = sortedCustomers[index];
            return _buildCustomerAnalyticsCard(customer);
          },
        );
      },
    );
  }

  Widget _buildCustomerAnalyticsCard(CustomerModel customer) {
    // Calculate average per order
    final avgPerOrder = customer.orderCount > 0
        ? customer.totalPurchases / customer.orderCount
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : 'C',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name, style: AppTextStyles.tableRowPrimary),
                      const SizedBox(height: 4),
                      Text(
                        customer.phone,
                        style: AppTextStyles.tableRowSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: AppColors.borderGrey, height: 1),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Sales',
                    '₹${customer.totalPurchases.toStringAsFixed(2)}',
                    Icons.shopping_cart_outlined,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Orders',
                    '${customer.orderCount}',
                    Icons.receipt_long_outlined,
                    AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Avg/Order',
                    '₹${avgPerOrder.toStringAsFixed(2)}',
                    Icons.trending_up_outlined,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Balance',
                    '₹${customer.balance.abs().toStringAsFixed(2)}',
                    customer.balance < 0
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    customer.balance < 0 ? AppColors.error : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No customer analytics available',
            style: AppTextStyles.customContainerTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
