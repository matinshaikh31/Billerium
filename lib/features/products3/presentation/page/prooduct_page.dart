import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/products3/domain/entity/product_model.dart';
import 'package:billing_software/features/products3/presentation/cubit/product_cubit.dart';
import 'package:billing_software/features/products3/presentation/cubit/product_form_cubit.dart';
import 'package:billing_software/features/products3/presentation/widget/product_form_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().initializeProductsPagination();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, state),
              const SizedBox(height: 20),
              _buildProductsTable(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProductState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Products',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your product inventory',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showProductDialog(context),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context, ProductState state) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildTableHeader(context),
          const SizedBox(height: 20),
          if (state.isLoading && state.filteredProducts.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (state.filteredProducts.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: [
                _buildTableHeaders(),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: state.filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductRow(state.filteredProducts[index]);
                  },
                ),
                if (state.totalPages > 1 && state.searchQuery.isEmpty)
                  _buildPagination(context, state),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: context.read<ProductCubit>().searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or SKU...',
              prefixIcon: const Icon(CupertinoIcons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) =>
                context.read<ProductCubit>().searchProducts(value),
          ),
        ),
        const SizedBox(width: 16),
        BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return DropdownButton<String>(
              value: context.read<ProductCubit>().state.selectedCategoryFilter,
              hint: const Text('All Categories'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...categoryState.categories.map((cat) {
                  return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                }).toList(),
              ],
              onChanged: (value) =>
                  context.read<ProductCubit>().filterByCategory(value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Product', style: _headerStyle())),
          Expanded(child: Text('Category', style: _headerStyle())),
          Expanded(child: Text('SKU', style: _headerStyle())),
          Expanded(child: Text('Price', style: _headerStyle())),
          Expanded(child: Text('Discount', style: _headerStyle())),
          Expanded(child: Text('Final Price', style: _headerStyle())),
          Expanded(child: Text('Stock', style: _headerStyle())),
          SizedBox(width: 100, child: Text('Actions', style: _headerStyle())),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey[600],
    );
  }

  Widget _buildProductRow(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              product.name,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                final category = state.categories.firstWhere(
                  (cat) => cat.id == product.categoryId,
                  orElse: () => CategoryModel(
                    id: '',
                    name: 'Unknown',
                    defaultDiscountPercent: 0,
                    createdAt: Timestamp.now(),
                    updatedAt: Timestamp.now(),
                  ),
                );
                return Text(
                  category.name,
                  style: GoogleFonts.inter(fontSize: 14),
                );
              },
            ),
          ),
          Expanded(
            child: Text(
              product.sku ?? 'N/A',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              '₹${product.price.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${product.discountPercent?.toStringAsFixed(0) ?? '0'}%',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              '₹${product.finalPrice.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ),
          Expanded(child: _buildStockBadge(product.stockQty)),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () =>
                      _showProductDialog(context, product: product),
                  color: Colors.grey[600],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _showDeleteDialog(context, product),
                  color: Colors.red[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(int stock) {
    Color color;
    if (stock <= 5) {
      color = Colors.red;
    } else if (stock <= 20) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        stock.toString(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context, ProductState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.currentPage > 1
                ? () => context.read<ProductCubit>().fetchNextProductsPage(
                    page: state.currentPage - 1,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Page ${state.currentPage} of ${state.totalPages}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.currentPage < state.totalPages
                ? () => context.read<ProductCubit>().fetchNextProductsPage(
                    page: state.currentPage + 1,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, {ProductModel? product}) {
    final formCubit = context.read<ProductFormCubit>();
    formCubit.initializeForm(product);

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: formCubit,
        child: ProductFormDialog(product: product),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Product',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProductCubit>().deleteProduct(product.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }
}
