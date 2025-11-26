import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_form_cubit.dart';
import 'package:billing_software/features/categories/presentation/widget/category_form_dilog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    // 🔥 Responsive Sizes
    final double iconBoxSize = isMobile ? 40 : 48;
    final double iconSize = isMobile ? 20 : 24;
    final double padding = isMobile ? 16 : 20;
    final double titleFont = isMobile ? 15 : 18;
    final double productFont = isMobile ? 12 : 14;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.categoryCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- HEADER ROW ----------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: AppColors.categoryAccentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category,
                  color: AppColors.categoryAccent,
                  size: iconSize,
                ),
              ),

              SizedBox(width: isMobile ? 10 : 12),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.tableRowPrimary.copyWith(
                        fontSize: titleFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "0 products",
                      style: AppTextStyles.tableRowSecondary.copyWith(
                        fontSize: productFont,
                      ),
                    ),
                  ],
                ),
              ),

              // ACTION BUTTONS
              if (!isMobile) ...[
                // Desktop Buttons
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: () => _showEditDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.warning,
                  onPressed: () => _showDeleteDialog(context),
                ),
              ] else ...[
                // Mobile: Smaller buttons
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showEditDialog(context),
                ),
                SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.warning,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showDeleteDialog(context),
                ),
              ],
            ],
          ),

          const Spacer(),

          // ---------------- FOOTER ----------------
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Default Discount',
                  style: AppTextStyles.tableRowSecondary.copyWith(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${category.defaultDiscountPercent.toStringAsFixed(0)}%',
                  style: AppTextStyles.tableRowBoldValue.copyWith(
                    fontSize: isMobile ? 14 : 15,
                    color: AppColors.categoryAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final formCubit = context.read<CategoryFormCubit>();
    formCubit.setEditingCategory(category);

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: formCubit,
        child: const CategoryFormDialog(isEditing: true),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Delete Category', style: AppTextStyles.dialogHeading),
        content: Text(
          'Are you sure you want to delete "${category.name}"?',
          style: AppTextStyles.dialogSubheading,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.tableRowSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryCubit>().deleteCategory(category.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.secondary,
            ),
            child: Text('Delete', style: AppTextStyles.tableRowPrimary),
          ),
        ],
      ),
    );
  }
}
