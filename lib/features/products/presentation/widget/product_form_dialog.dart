import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_form_cubit.dart';

class ProductFormDialog extends StatelessWidget {
  final bool isEdit;
  final String? productId;

  const ProductFormDialog({super.key, this.isEdit = false, this.productId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxWidth: 600),
        child: BlocConsumer<ProductFormCubit, ProductFormState>(
          listener: (context, state) {
            if (state.isSuccess) {
              Navigator.of(context).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.isEditMode
                        ? 'Product updated successfully'
                        : 'Product created successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          state.isEditMode ? 'Edit Product' : 'Add Product',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Product Name *',
                      value: state.name,
                      onChanged: context.read<ProductFormCubit>().updateName,
                      icon: Icons.inventory_2,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'SKU',
                      value: state.sku,
                      onChanged: context.read<ProductFormCubit>().updateSku,
                      icon: Icons.qr_code,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Category ID *',
                      value: state.categoryId,
                      onChanged: context
                          .read<ProductFormCubit>()
                          .updateCategoryId,
                      icon: Icons.category,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Price *',
                            value: state.price,
                            onChanged: context
                                .read<ProductFormCubit>()
                                .updatePrice,
                            icon: Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Cost Price *',
                            value: state.costPrice,
                            onChanged: context
                                .read<ProductFormCubit>()
                                .updateCostPrice,
                            icon: Icons.price_check,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Discount %',
                            value: state.discountPercent,
                            onChanged: context
                                .read<ProductFormCubit>()
                                .updateDiscountPercent,
                            icon: Icons.discount,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Tax % *',
                            value: state.taxPercent,
                            onChanged: context
                                .read<ProductFormCubit>()
                                .updateTaxPercent,
                            icon: Icons.percent,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Stock Quantity *',
                      value: state.stockQty,
                      onChanged: context
                          .read<ProductFormCubit>()
                          .updateStockQty,
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Image URL',
                      value: state.imageUrl,
                      onChanged: context
                          .read<ProductFormCubit>()
                          .updateImageUrl,
                      icon: Icons.image,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () async {
                                  final success = await context
                                      .read<ProductFormCubit>()
                                      .submitForm();
                                  if (success) {
                                    // Form cubit listener will handle navigation
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(state.isEditMode ? 'Update' : 'Create'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : null,
      onChanged: onChanged,
    );
  }
}
