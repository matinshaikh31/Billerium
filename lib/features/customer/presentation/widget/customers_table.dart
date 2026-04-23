import 'package:billing_software/core/routes/routes.dart';
import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomersTable extends StatelessWidget {
  final List<CustomerModel> customers;
  final VoidCallback Function(CustomerModel) onEdit;
  final VoidCallback Function(CustomerModel) onDelete;

  const CustomersTable({
    super.key,
    required this.customers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Customer', style: AppTextStyles.tabelHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Phone', style: AppTextStyles.tabelHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Balance', style: AppTextStyles.tabelHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Total Sales', style: AppTextStyles.tabelHeader),
                ),
                Expanded(
                  flex: 1,
                  child: Text('Orders', style: AppTextStyles.tabelHeader),
                ),
                SizedBox(
                  width: 100,
                  child: Text('Actions', style: AppTextStyles.tabelHeader),
                ),
              ],
            ),
          ),
          // Table Rows
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return _buildTableRow(context, customer);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, CustomerModel customer) {
    return InkWell(
      onTap: () => context.push(Routes.customerDetail, extra: customer),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
        ),
        child: Row(
          children: [
            // Customer Name + Avatar
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : 'C',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: AppTextStyles.tableRowPrimary,
                        ),
                        if (customer.email != null)
                          Text(
                            customer.email!,
                            style: AppTextStyles.tableRowSecondary,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Phone
            Expanded(
              flex: 2,
              child: Text(customer.phone, style: AppTextStyles.tableRowPrimary),
            ),
            // Balance
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: customer.hasDebt
                      ? AppColors.errorSoft
                      : customer.hasCredit
                      ? AppColors.successSoft
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '₹${customer.balance.abs().toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: customer.hasDebt
                        ? AppColors.error
                        : customer.hasCredit
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            // Total Sales
            Expanded(
              flex: 2,
              child: Text(
                '₹${customer.totalPurchases.toStringAsFixed(2)}',
                style: AppTextStyles.tableRowPrimary,
              ),
            ),
            // Orders
            Expanded(
              flex: 1,
              child: Text(
                '${customer.orderCount}',
                style: AppTextStyles.tableRowPrimary,
              ),
            ),
            // Actions
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: AppColors.primary,
                    onPressed: () => onEdit(customer)(),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: AppColors.error,
                    onPressed: () => onDelete(customer)(),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
