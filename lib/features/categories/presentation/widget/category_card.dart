import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_form_cubit.dart';
import 'package:billing_software/features/categories/presentation/widget/category_form_dilog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final productCount = 0; // TODO: Connect to actual product count

    return Container(
      decoration: BoxDecoration(
        color: AppColors.categoryCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.categoryAccentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category,
                  color: AppColors.categoryAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppTextStyles.tableRowPrimary.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$productCount products',
                      style: AppTextStyles.tableRowSecondary,
                    ),
                  ],
                ),
              ),
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
            ],
          ),
          const Spacer(),
          // Footer (Default Discount)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${category.defaultDiscountPercent.toStringAsFixed(0)}%',
                  style: AppTextStyles.tableRowBoldValue.copyWith(
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
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
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
