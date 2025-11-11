import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_form_cubit.dart';
import 'package:billing_software/features/categories/presentation/widget/category_card.dart';
import 'package:billing_software/features/categories/presentation/widget/category_form_dilog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocListener<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state.isLoading && state.categories.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.categories.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildCategoriesGrid(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(Icons.category_outlined, size: 28, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categories', style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  'Organize your products into categories',
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCategoryDialog(context),
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: Text(
              'Add Category',
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

  Widget _buildCategoriesGrid(BuildContext context, CategoryState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        return CategoryCard(category: state.categories[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: AppColors.borderGrey),
          const SizedBox(height: 16),
          Text('No categories yet', style: AppTextStyles.tableRowPrimary),
          const SizedBox(height: 8),
          Text(
            'Create your first category to get started',
            style: AppTextStyles.tableRowSecondary,
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final formCubit = context.read<CategoryFormCubit>();
    if (category != null) {
      formCubit.setEditingCategory(category);
    } else {
      formCubit.clearForm();
    }

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: formCubit,
        child: CategoryFormDialog(isEditing: category != null),
      ),
    );
  }
}
