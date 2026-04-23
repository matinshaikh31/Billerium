import 'package:billing_software/core/routes/routes.dart';
import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasDebt = customer.balance < 0;
    final hasCredit = customer.balance > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to customer detail page
          context.push(Routes.customerDetail, extra: customer);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Customer Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : 'C',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: AppTextStyles.tableRowPrimary,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: AppTextStyles.tableRowSecondary,
                    ),
                    if (customer.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        customer.email!,
                        style: AppTextStyles.tableRowSecondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Balance Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: hasDebt
                      ? AppColors.errorSoft
                      : hasCredit
                      ? AppColors.successSoft
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasDebt
                        ? AppColors.error.withValues(alpha: 0.3)
                        : hasCredit
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.borderGrey,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      hasDebt
                          ? 'Debt'
                          : hasCredit
                          ? 'Credit'
                          : 'Balanced',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hasDebt
                            ? AppColors.error
                            : hasCredit
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${customer.balance.abs().toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: hasDebt
                            ? AppColors.error
                            : hasCredit
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action Buttons
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
