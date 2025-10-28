import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/category_cubit.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/category_list_item.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().loadCategories();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(
        onSubmit: (name, discount) {
          context.read<CategoryCubit>().createCategory(name, discount);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          if (!ResponsiveHelper.isMobile(context))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButton(
                text: 'Add Category',
                icon: Icons.add,
                onPressed: _showAddCategoryDialog,
              ),
            ),
        ],
      ),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.categories.isNotEmpty
                    ? Colors.green
                    : Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget(message: 'Loading categories...');
          }

          if (state.categories.isEmpty && state.message != null) {
            return CustomErrorWidget(
              message: state.message!,
              onRetry: () => context.read<CategoryCubit>().loadCategories(),
            );
          }

          if (state.categories.isEmpty) {
            return EmptyStateWidget(
              message: 'No categories yet',
              icon: Icons.category_outlined,
              onAction: _showAddCategoryDialog,
              actionLabel: 'Add Category',
            );
          }

          return ResponsiveWidget(
            mobile: _buildMobileList(state.categories),
            desktop: _buildDesktopGrid(state.categories),
          );
        },
      ),
      floatingActionButton: ResponsiveHelper.isMobile(context)
          ? FloatingActionButton(
              onPressed: _showAddCategoryDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMobileList(List categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryListItem(category: categories[index]);
      },
    );
  }

  Widget _buildDesktopGrid(List categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryListItem(category: categories[index]);
      },
    );
  }
}
