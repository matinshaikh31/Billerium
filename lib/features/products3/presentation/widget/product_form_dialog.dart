import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/products3/domain/entity/product_model.dart';
import 'package:billing_software/features/products3/presentation/cubit/product_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductFormDialog extends StatelessWidget {
  final ProductModel? product;

  const ProductFormDialog({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductFormCubit, ProductFormState>(
      listener: (context, state) {
        if (state.message != null && (state.message?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.message!.contains('success')
                  ? Colors.green
                  : Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ProductFormCubit>();

        return AlertDialog(
          title: Text(
            product == null ? 'Add Product' : 'Edit Product',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: cubit.formKey,
            child: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: cubit.nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value?.trim().isEmpty ?? true
                          ? 'Please enter product name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<CategoryCubit, CategoryState>(
                      builder: (context, categoryState) {
                        return DropdownButtonFormField<String>(
                          value: cubit.selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: categoryState.categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              cubit.setSelectedCategory(value),
                          validator: (value) =>
                              value == null ? 'Please select category' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: cubit.priceController,
                            decoration: InputDecoration(
                              labelText: 'Price',
                              prefixText: '₹',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true)
                                return 'Required';
                              if (double.tryParse(value!) == null)
                                return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: cubit.discountController,
                            decoration: InputDecoration(
                              labelText: 'Discount %',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.trim().isNotEmpty ?? false) {
                                final discount = double.tryParse(value!);
                                if (discount == null ||
                                    discount < 0 ||
                                    discount > 100) {
                                  return 'Invalid';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: cubit.skuController,
                            decoration: InputDecoration(
                              labelText: 'SKU',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: cubit.stockController,
                            decoration: InputDecoration(
                              labelText: 'Stock Quantity',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true)
                                return 'Required';
                              if (int.tryParse(value!) == null)
                                return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: state.isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () => cubit.submitForm(product, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      product == null ? 'Create' : 'Update',
                      style: GoogleFonts.inter(),
                    ),
            ),
          ],
        );
      },
    );
  }
}
