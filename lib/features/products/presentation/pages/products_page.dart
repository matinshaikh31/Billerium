import 'package:billing_software/core/widgets/app_drawer.dart';
import 'package:billing_software/features/products/presentation/widget/product_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/responsive/responsive_helper.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/models/product_model.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_form_cubit.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  void _showProductForm({ProductModel? product}) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (context) {
          final cubit = ProductFormCubit(
            context.read<ProductCubit>().repository,
          );
          if (product != null) {
            cubit.setEditMode(product);
          }
          return cubit;
        },
        child: ProductFormDialog(isEdit: true, productId: product?.id),
      ),
    ).then((result) {
      if (result == true) {
        context.read<ProductCubit>().loadProducts();
      }
    });
  }

  void _deleteProduct(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductCubit>().deleteProduct(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Products'),
            Text(
              'Manage your product inventory',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          if (!ResponsiveHelper.isMobile(context))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showProductForm(),
              ),
            ),
        ],
      ),
      drawer: ResponsiveHelper.isMobile(context) ? const AppDrawer() : null,
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.products.isNotEmpty
                    ? Colors.green
                    : Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget(message: 'Loading products...');
          }

          if (state.products.isEmpty && state.message != null) {
            return CustomErrorWidget(
              message: state.message!,
              onRetry: () => context.read<ProductCubit>().loadProducts(),
            );
          }

          if (state.products.isEmpty) {
            return EmptyStateWidget(
              message: 'No products yet',
              icon: Icons.inventory_2_outlined,
              onAction: () => _showProductForm(),
              actionLabel: 'Add Product',
            );
          }

          return ResponsiveWidget(
            mobile: _buildProductContent(state),
            desktop: Row(
              children: [
                const SizedBox(width: 250, child: AppDrawer()),
                Expanded(child: _buildProductContent(state)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ResponsiveHelper.isMobile(context)
          ? FloatingActionButton(
              onPressed: () => _showProductForm(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildProductContent(ProductState state) {
    final categories = context.read<ProductCubit>().getCategories();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: context.read<ProductCubit>().searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or SKU...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: state.selectedCategory,
                  underline: const SizedBox(),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ProductCubit>().updateSelectedCategory(
                        value,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : _buildProductTable(state.filteredProducts),
        ),
      ],
    );
  }

  Widget _buildProductTable(List<ProductModel> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('SKU')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Discount')),
              DataColumn(label: Text('Final Price')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('Actions')),
            ],
            rows: products.map((product) {
              final finalPrice = product.discountPercent != null
                  ? product.price * (1 - product.discountPercent! / 100)
                  : product.price;

              final isLowStock = product.stockQty < 10;

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(Text(product.categoryId)),
                  DataCell(Text(product.sku ?? '-')),
                  DataCell(Text('₹${product.price.toStringAsFixed(2)}')),
                  DataCell(
                    Text(
                      product.discountPercent != null
                          ? '${product.discountPercent}%'
                          : '0%',
                    ),
                  ),
                  DataCell(
                    Text(
                      '₹${finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLowStock ? Colors.red[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${product.stockQty}',
                        style: TextStyle(
                          color: isLowStock ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showProductForm(product: product),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteProduct(product.id, product.name),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
