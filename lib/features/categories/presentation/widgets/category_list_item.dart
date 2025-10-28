import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/category_model.dart';
import '../cubit/category_cubit.dart';
import 'category_form_dialog.dart';

class CategoryListItem extends StatelessWidget {
  final CategoryModel category;

  const CategoryListItem({super.key, required this.category});

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CategoryFormDialog(
        category: category,
        onSubmit: (name, discount) {
          context.read<CategoryCubit>().updateCategory(
                category.copyWith(
                  name: name,
                  defaultDiscountPercent: discount,
                  updatedAt: DateTime.now(),
                ),
              );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryCubit>().deleteCategory(category.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.category,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Default Discount: ${category.defaultDiscountPercent.toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditDialog(context),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

