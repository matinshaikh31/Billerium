import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/models/category_model.dart';

class CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category;
  final Function(String name, double discount) onSubmit;

  const CategoryFormDialog({
    super.key,
    this.category,
    required this.onSubmit,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _discountController = TextEditingController(
      text: widget.category?.defaultDiscountPercent.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _nameController.text.trim(),
        double.parse(_discountController.text),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Category' : 'Add Category'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Category Name',
                hint: 'Enter category name',
                controller: _nameController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Category name'),
                prefixIcon: const Icon(Icons.category),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Default Discount (%)',
                hint: 'Enter default discount percentage',
                controller: _discountController,
                validator: (value) =>
                    Validators.validatePercentage(value, 'Discount'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                prefixIcon: const Icon(Icons.discount),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: isEdit ? 'Update' : 'Add',
          onPressed: _handleSubmit,
        ),
      ],
    );
  }
}

