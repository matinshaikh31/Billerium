import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_form_cubit.dart';
import 'package:billing_software/features/categories/presentation/widget/category_form_dilog.dart';
import 'package:billing_software/features/categories/presentation/widget/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            _showSnack(state.successMessage!, AppColors.success);
          }
          if (state.errorMessage != null) {
            _showSnack(state.errorMessage!, AppColors.error);
          }
        },
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // ─────────────────────────────────────────────────────────────── HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.category_outlined,
            size: 28,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Categories", style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  "Organize your products into categories",
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _openCategoryDialog(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add Category",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────── BODY
  Widget _buildBody() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state.isLoading && state.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.categories.isEmpty) return _buildEmptyState();

        return ResponsiveCustomBuilder(
          mobileBuilder: (_) => _buildGrid(state.categories, 1, 140),
          tabletBuilder: (_) => _buildGrid(state.categories, 2, 150),
          desktopBuilder: (_) => _buildGrid(state.categories, 3, 160),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────── GRID
  Widget _buildGrid(List<CategoryModel> items, int crossAxisCount, double h) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (_, i) {
        return CategoryCard(category: items[i]);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────── EMPTY UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.category_outlined,
            size: 80,
            color: AppColors.borderGrey,
          ),
          const SizedBox(height: 16),
          Text("No categories yet", style: AppTextStyles.tableRowPrimary),
          const SizedBox(height: 8),
          Text(
            "Create your first category to get started",
            style: AppTextStyles.tableRowSecondary,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────── DIALOG
  void _openCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final cubit = context.read<CategoryFormCubit>();

    if (category != null) {
      cubit.setEditingCategory(category);
    } else {
      cubit.clearForm();
    }

    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CategoryFormDialog(isEditing: category != null),
      ),
    );
  }
}
