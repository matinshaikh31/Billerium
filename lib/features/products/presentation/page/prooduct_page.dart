import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/utils/helpers.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/core/widgets/pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/products/presentation/cubit/product_cubit.dart';
import 'package:billing_software/features/products/presentation/cubit/product_form_cubit.dart';
import 'package:billing_software/features/products/presentation/widget/product_form_dialog.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/categories/domain/antity/category_model.dart';

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
        return ResponsiveCustomBuilder(
          mobileBuilder: (width) => _buildMobileLayout(state),
          tabletBuilder: (width) => _buildTabletLayout(state),
          desktopBuilder: (width) => _buildDesktopLayout(state),
        );
      },
    );
  }

  // ===================== MOBILE LAYOUT =====================
  Widget _buildMobileLayout(ProductState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileHeader(),
          const SizedBox(height: 16),
          _buildMobileSearchFilter(),
          const SizedBox(height: 16),
          _buildMobileProductsList(state),
        ],
      ),
    );
  }

  // ===================== TABLET LAYOUT =====================
  Widget _buildTabletLayout(ProductState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildProductsTable(context, state),
        ],
      ),
    );
  }

  // ===================== DESKTOP LAYOUT =====================
  Widget _buildDesktopLayout(ProductState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildProductsTable(context, state),
        ],
      ),
    );
  }

  // ===================== MOBILE HEADER =====================
  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Products',
                  style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showProductDialog(context),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: Text(
                'Add Product',
                style: GoogleFonts.inter(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== HEADER =====================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.secondary,
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 30, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Products', style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  'Manage your product inventory',
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showProductDialog(context),
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: Text(
              'Add Product',
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

  // ===================== MOBILE SEARCH + FILTER =====================
  Widget _buildMobileSearchFilter() {
    return Column(
      children: [
        TextField(
          controller: context.read<ProductCubit>().searchController,
          decoration: InputDecoration(
            hintText: 'Search by name or SKU...',
            hintStyle: AppTextStyles.hintText,
            prefixIcon: Icon(
              CupertinoIcons.search,
              size: 20,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) =>
              context.read<ProductCubit>().searchProducts(value),
        ),
        const SizedBox(height: 12),
        BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderGrey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: context.read<ProductCubit>().state.selectedCategory,
                  isExpanded: true,
                  hint: Text(
                    'All Categories',
                    style: AppTextStyles.tableRowRegular,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'All',
                      child: Text('All Categories'),
                    ),
                    ...categoryState.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(
                          cat.name,
                          style: AppTextStyles.tableRowNormal,
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) => context
                      .read<ProductCubit>()
                      .filterByCategory(value ?? 'All'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ===================== MOBILE PRODUCTS LIST =====================
  Widget _buildMobileProductsList(ProductState state) {
    final displayProducts = state.searchQuery.isNotEmpty
        ? state.searchedProducts
        : state.filteredProducts;

    if (state.isLoading && displayProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (displayProducts.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: displayProducts.length,
          itemBuilder: (context, index) {
            return _buildMobileProductCard(displayProducts[index]);
          },
        ),
        // Mobile Pagination - Only show when not searching
        if (state.totalPages > 1 && state.searchQuery.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DynamicPagination(
              currentPage: state.currentPage,
              totalPages: state.totalPages,
              onPageChanged: (page) {
                context.read<ProductCubit>().fetchNextProductsPage(page: page);
              },
            ),
          ),
      ],
    );
  }

  // ===================== MOBILE PRODUCT CARD =====================
  Widget _buildMobileProductCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  capitalizeWords(product.name),
                  style: AppTextStyles.tableRowPrimary,
                ),
              ),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined, size: 18),
                      title: Text('Edit'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () => _showProductDialog(context, product: product),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      title: Text(
                        'Delete',
                        style: TextStyle(color: AppColors.warning),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () => _showDeleteDialog(context, product),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SKU',
                      style: AppTextStyles.tableRowSecondary.copyWith(
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.sku ?? 'N/A',
                      style: AppTextStyles.tableRowNormal,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock',
                      style: AppTextStyles.tableRowSecondary.copyWith(
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStockBadge(product.stockQty),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: AppTextStyles.tableRowSecondary.copyWith(
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: AppTextStyles.tableRowNormal,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discount',
                      style: AppTextStyles.tableRowSecondary.copyWith(
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.discountPercent?.toStringAsFixed(0) ?? '0'}%',
                      style: AppTextStyles.tableRowRegular,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Final',
                      style: AppTextStyles.tableRowSecondary.copyWith(
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.finalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.tableRowBoldValue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== TABLE SECTION =====================
  Widget _buildProductsTable(BuildContext context, ProductState state) {
    final displayProducts = state.searchQuery.isNotEmpty
        ? state.searchedProducts
        : state.filteredProducts;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          _buildTableSearchFilter(context),
          const SizedBox(height: 20),
          if (state.isLoading && displayProducts.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (displayProducts.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: [
                _buildTableHeaders(),
                Divider(height: 1, color: AppColors.divider),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.divider),
                  itemCount: displayProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductRow(displayProducts[index]);
                  },
                ),
                // Desktop/Tablet Pagination - Only show when not searching
                if (state.totalPages > 1 && state.searchQuery.isEmpty)
                  _buildPagination(context, state),
              ],
            ),
        ],
      ),
    );
  }

  // ===================== SEARCH + FILTER =====================
  Widget _buildTableSearchFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: context.read<ProductCubit>().searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or SKU...',
              hintStyle: AppTextStyles.hintText,
              prefixIcon: Icon(
                CupertinoIcons.search,
                size: 20,
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderGrey),
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
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderGrey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: context.read<ProductCubit>().state.selectedCategory,
                  hint: Text(
                    'All Categories',
                    style: AppTextStyles.tableRowRegular,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'All',
                      child: Text('All Categories'),
                    ),
                    ...categoryState.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(
                          cat.name,
                          style: AppTextStyles.tableRowNormal,
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) => context
                      .read<ProductCubit>()
                      .filterByCategory(value ?? 'All'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ===================== TABLE HEADERS =====================
  Widget _buildTableHeaders() {
    return Container(
      color: AppColors.headerBackground,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text('Product', style: AppTextStyles.tabelHeader),
          ),
          Expanded(child: Text('Category', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('SKU', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('Price', style: AppTextStyles.tabelHeader)),
          Expanded(child: Text('Discount', style: AppTextStyles.tabelHeader)),
          Expanded(
            child: Text('Final Price', style: AppTextStyles.tabelHeader),
          ),
          Expanded(child: Text('Stock', style: AppTextStyles.tabelHeader)),
          SizedBox(
            width: 100,
            child: Text('Actions', style: AppTextStyles.tabelHeader),
          ),
        ],
      ),
    );
  }

  // ===================== TABLE ROWS =====================
  Widget _buildProductRow(ProductModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              capitalizeWords(product.name),
              style: AppTextStyles.tableRowPrimary,
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
                  style: AppTextStyles.tableRowSecondary,
                );
              },
            ),
          ),
          Expanded(
            child: Text(
              product.sku ?? 'N/A',
              style: AppTextStyles.tableRowSecondary,
            ),
          ),
          Expanded(
            child: Text(
              '₹${product.price.toStringAsFixed(0)}',
              style: AppTextStyles.tableRowNormal,
            ),
          ),
          Expanded(
            child: Text(
              '${product.discountPercent?.toStringAsFixed(0) ?? '0'}%',
              style: AppTextStyles.tableRowRegular,
            ),
          ),
          Expanded(
            child: Text(
              '₹${product.finalPrice.toStringAsFixed(0)}',
              style: AppTextStyles.tableRowBoldValue,
            ),
          ),
          Expanded(child: _buildStockBadge(product.stockQty)),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      _showProductDialog(context, product: product),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  onPressed: () => _showDeleteDialog(context, product),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== STOCK BADGE =====================
  Widget _buildStockBadge(int stock) {
    Color color;
    if (stock <= 5) {
      color = AppColors.error;
    } else if (stock <= 20) {
      color = AppColors.warning;
    } else {
      color = AppColors.success;
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

  // ===================== EMPTY STATE =====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.borderGrey,
            ),
            const SizedBox(height: 16),
            Text('No products found', style: AppTextStyles.tableRowPrimary),
          ],
        ),
      ),
    );
  }

  // ===================== PAGINATION =====================
  Widget _buildPagination(BuildContext context, ProductState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: DynamicPagination(
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        onPageChanged: (page) {
          context.read<ProductCubit>().fetchNextProductsPage(page: page);
        },
      ),
    );
  }

  // ===================== DIALOGS =====================
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

  // Updated delete dialog
  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Delete Product', style: AppTextStyles.dialogHeading),
        content: Text(
          'Are you sure you want to delete "${capitalizeWords(product.name)}"?',
          style: AppTextStyles.dialogSubheading,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.tableRowSecondary),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog first
              await context.read<ProductCubit>().handleDeleteProduct(
                context,
                product,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.secondary,
            ),
            child: Text('Delete', style: AppTextStyles.tableRowPrimary),
          ),
        ],
      ),
    );
  }
}
