import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/product_cubit.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          if (!ResponsiveHelper.isMobile(context))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButton(
                text: 'Add Product',
                icon: Icons.add,
                onPressed: () {
                  // TODO: Implement add product dialog
                },
              ),
            ),
        ],
      ),
      drawer: ResponsiveHelper.isMobile(context) ? const AppDrawer() : null,
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingWidget(message: 'Loading products...');
          }

          if (state is ProductError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () => context.read<ProductCubit>().loadProducts(),
            );
          }

          if (state is ProductLoaded) {
            if (state.products.isEmpty) {
              return EmptyStateWidget(
                message: 'No products yet',
                icon: Icons.inventory_2_outlined,
                onAction: () {
                  // TODO: Implement add product dialog
                },
                actionLabel: 'Add Product',
              );
            }

            return ResponsiveWidget(
              mobile: _buildProductList(state.products),
              desktop: Row(
                children: [
                  const SizedBox(width: 250, child: AppDrawer()),
                  Expanded(child: _buildProductList(state.products)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: ResponsiveHelper.isMobile(context)
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Implement add product dialog
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildProductList(List products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.inventory_2,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Stock: ${product.stockQty} | Price: ₹${product.price}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.isLowStock)
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // TODO: Implement edit
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

