import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/presentation/cubit/create_bill_cubit.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/core/services/firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billing_software/core/utils/helpers.dart';
import 'package:intl/intl.dart';

class CreateBillPage extends StatefulWidget {
  const CreateBillPage({super.key});

  @override
  State<CreateBillPage> createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateBillCubit, CreateBillState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.message!.contains('success')
                  ? AppColors.success
                  : AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<CreateBillCubit, CreateBillState>(
        builder: (context, state) {
          return ResponsiveCustomBuilder(
            mobileBuilder: (width) => _buildMobileLayout(context, state),
            tabletBuilder: (width) => _buildTabletLayout(context, state),
            desktopBuilder: (width) => _buildDesktopLayout(context, state),
          );
        },
      ),
    );
  }

  // ===================== MOBILE LAYOUT =====================
  Widget _buildMobileLayout(BuildContext context, CreateBillState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileHeader(),
            const SizedBox(height: 16),
            _buildProductSearch(context),
            const SizedBox(height: 16),
            _buildCartItems(context, state),
            const SizedBox(height: 16),
            _buildCustomerDetails(context, state),
            const SizedBox(height: 16),
            _buildBillDiscount(context, state),
            const SizedBox(height: 16),
            _buildPaymentDetails(context, state),
            const SizedBox(height: 16),
            _buildMobileSummary(context, state),
          ],
        ),
      ),
    );
  }

  // ===================== TABLET LAYOUT =====================
  Widget _buildTabletLayout(BuildContext context, CreateBillState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildProductSearch(context),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(children: [_buildCartItems(context, state)]),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _buildCustomerDetails(context, state),
                      const SizedBox(height: 20),
                      _buildBillDiscount(context, state),
                      const SizedBox(height: 20),
                      _buildPaymentDetails(context, state),
                      const SizedBox(height: 20),
                      _buildSummary(context, state),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== DESKTOP LAYOUT =====================
  Widget _buildDesktopLayout(BuildContext context, CreateBillState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildProductSearch(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _buildCartItems(context, state)),
                ],
              ),
            ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Expanded(child: _buildCustomerDetails(context, state)),
            //       const SizedBox(width: 20),
            //       Expanded(child: _buildBillDiscount(context, state)),
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Expanded(child: _buildBillDiscount(context, state)),
            //       const SizedBox(width: 20),
            //       Expanded(child: _buildPaymentDetails(context, state)),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded(flex: 2, child: _buildCartItems(context, state)),
                  // const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildCustomerDetails(context, state),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildBillDiscount(context, state)),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildPaymentDetails(context, state),
                            ),
                          ],
                        ),
                        // _buildBillDiscount(context, state),
                        // const SizedBox(height: 20),
                        // _buildPaymentDetails(context, state),
                        const SizedBox(height: 20),
                        _buildSummary(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      child: Row(
        children: [
          Icon(Icons.add_shopping_cart, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Bill',
                  style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  'Point of Sale',
                  style: AppTextStyles.headerSubheading.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== HEADER =====================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(color: AppColors.blueGreyBorder),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.add_shopping_cart, size: 30, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Bill', style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  'Point of Sale - Create new invoice',
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== PRODUCT SEARCH =====================
  Widget _buildProductSearch(BuildContext context) {
    return _buildCardWrapper(
      title: 'Product Search',
      icon: Icons.search,
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, categoryState) {
          final categories = categoryState.categories;

          return Autocomplete<ProductModel>(
            optionsBuilder: (textEditingValue) async {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<ProductModel>.empty();
              }
              return await _searchProductsFromFirebase(textEditingValue.text);
            },
            displayStringForOption: (option) {
              final categoryName = option.getCategoryName(categories);
              return '${option.name} ($categoryName)';
            },
            onSelected: (selection) {
              final categoryName = selection.getCategoryName(categories);
              context.read<CreateBillCubit>().addProductToCart(
                selection,
                1,
                categoryName: categoryName,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${selection.name} ($categoryName) added to cart',
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    width: MediaQuery.of(context).size.width - 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: AppColors.divider),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        final categoryName = option.getCategoryName(categories);
                        final hasDiscount =
                            option.discountPercent != null &&
                            option.discountPercent! > 0;

                        return ListTile(
                          onTap: () => onSelected(option),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            capitalizeWords(option.name),
                            style: AppTextStyles.tableRowPrimary,
                          ),
                          subtitle: Text(
                            categoryName,
                            style: AppTextStyles.tableRowSecondary,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hasDiscount) ...[
                                Text(
                                  '₹${option.price.toStringAsFixed(2)}',
                                  style: AppTextStyles.tableRowSecondary
                                      .copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 11,
                                      ),
                                ),
                                Text(
                                  '₹${option.finalPrice.toStringAsFixed(2)}',
                                  style: AppTextStyles.tableRowBoldValue
                                      .copyWith(color: AppColors.success),
                                ),
                              ] else
                                Text(
                                  '₹${option.price.toStringAsFixed(2)}',
                                  style: AppTextStyles.tableRowBoldValue,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            fieldViewBuilder: (context, controller, focusNode, _) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Search by product name or scan barcode...',
                  hintStyle: AppTextStyles.hintText,
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.borderGrey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<ProductModel>> _searchProductsFromFirebase(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      final nameQuery = await FBFireStore.products
          .where('name', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('name', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
          .limit(10)
          .get();

      final skuQuery = await FBFireStore.products
          .where('sku', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('sku', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
          .limit(10)
          .get();

      final List<ProductModel> results = [];
      final Set<String> addedIds = {};

      for (var doc in nameQuery.docs) {
        if (addedIds.add(doc.id)) {
          results.add(ProductModel.fromJson(doc.data(), doc.id));
        }
      }
      for (var doc in skuQuery.docs) {
        if (addedIds.add(doc.id)) {
          results.add(ProductModel.fromJson(doc.data(), doc.id));
        }
      }
      return results;
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // ===================== CART ITEMS =====================
  Widget _buildCartItems(BuildContext context, CreateBillState state) {
    return _buildCardWrapper(
      title: 'Cart Items',
      icon: Icons.shopping_cart_outlined,
      child: state.cartItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: AppColors.borderGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items in cart',
                      style: AppTextStyles.tableRowSecondary,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: AppColors.divider),
              itemCount: state.cartItems.length,
              itemBuilder: (context, index) =>
                  _buildCartItemRow(context, state.cartItems[index]),
            ),
    );
  }

  Widget _buildCartItemRow(BuildContext context, BillItemModel item) {
    final hasDiscount = item.discountPercent > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeWords(item.displayName),
                  style: AppTextStyles.tableRowPrimary,
                ),
                if (item.categoryName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.categoryName!,
                    style: AppTextStyles.tableRowSecondary.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                if (hasDiscount) ...[
                  Row(
                    children: [
                      Text(
                        '₹${item.price.toStringAsFixed(2)}',
                        style: AppTextStyles.tableRowSecondary.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textSecondary.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.discountPercent.toStringAsFixed(0)}% OFF',
                          style: AppTextStyles.tableRowSecondary.copyWith(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${(item.price - (item.price * item.discountPercent / 100)).toStringAsFixed(2)} each',
                    style: AppTextStyles.tableRowSecondary.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else
                  Text(
                    '₹${item.price.toStringAsFixed(2)} each',
                    style: AppTextStyles.tableRowSecondary,
                  ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                color: AppColors.textSecondary,
                onPressed: () => context
                    .read<CreateBillCubit>()
                    .updateItemQuantity(item.productId, item.quantity - 1),
              ),
              Text(
                '${item.quantity}',
                style: AppTextStyles.tableRowNormal.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: AppColors.textSecondary,
                onPressed: () => context
                    .read<CreateBillCubit>()
                    .updateItemQuantity(item.productId, item.quantity + 1),
              ),
            ],
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '₹${item.itemTotal.toStringAsFixed(2)}',
              style: AppTextStyles.tableRowBoldValue,
              textAlign: TextAlign.right,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.error,
            onPressed: () => context.read<CreateBillCubit>().removeItemFromCart(
              item.productId,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== CUSTOMER DETAILS =====================
  Widget _buildCustomerDetails(BuildContext context, CreateBillState state) {
    return _buildCardWrapper(
      title: 'Customer Details *',
      icon: Icons.person_outline,
      child: Column(
        children: [
          // Bill Date Picker
          InkWell(
            onTap: () => _selectBillDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Bill Date *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
              ),
              child: Text(
                DateFormat('dd MMM yyyy').format(state.billDate),
                style: AppTextStyles.tableRowPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: context.read<CreateBillCubit>().customerNameController,
            decoration: InputDecoration(
              labelText: 'Customer Name *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Customer name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: context.read<CreateBillCubit>().customerPhoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: context.read<CreateBillCubit>().customerGstController,
            decoration: InputDecoration(
              labelText: 'Customer GST Number',
              hintText: 'e.g., 22AAAAA0000A1Z5',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              context.read<CreateBillCubit>().updateCustomerGstNumber(value);
            },
          ),
        ],
      ),
    );
  }

  // ===================== BILL DISCOUNT =====================
  Widget _buildBillDiscount(BuildContext context, CreateBillState state) {
    return _buildCardWrapper(
      title: 'Bill Discount (Optional)',
      icon: Icons.discount_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: context
                .read<CreateBillCubit>()
                .billDiscountPercentController,
            decoration: InputDecoration(
              labelText: 'Discount Percentage (%)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final percent = double.tryParse(value) ?? 0;
              context.read<CreateBillCubit>().updateBillDiscountPercent(
                percent,
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.divider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: AppTextStyles.tableRowSecondary),
              ),
              Expanded(child: Divider(color: AppColors.divider)),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: context
                .read<CreateBillCubit>()
                .billDiscountAmountController,
            decoration: InputDecoration(
              labelText: 'Discount Amount (₹)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixText: '₹ ',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final amount = double.tryParse(value) ?? 0;
              context.read<CreateBillCubit>().updateBillDiscountAmount(amount);
            },
          ),
          if (state.calculatedBillDiscount > 0)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bill Discount Applied: ₹${state.calculatedBillDiscount.toStringAsFixed(2)}',
                      style: AppTextStyles.tableRowBoldValue.copyWith(
                        color: AppColors.success,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ===================== PAYMENT DETAILS =====================
  Widget _buildPaymentDetails(BuildContext context, CreateBillState state) {
    return _buildCardWrapper(
      title: 'Payment Details *',
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: context
                .read<CreateBillCubit>()
                .amountReceivedController,
            decoration: InputDecoration(
              labelText: 'Amount Received (₹) *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: '₹',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final amount = double.tryParse(value) ?? 0;
              context.read<CreateBillCubit>().updateAmountReceived(amount);
            },
            validator: (value) {
              final amount = double.tryParse(value ?? '0') ?? 0;
              // if (amount <= 0) {
              //   return 'Amount must be greater than 0';
              // }
              if (amount > state.grandTotal) {
                return 'Amount cannot exceed total (₹${state.grandTotal.toStringAsFixed(2)})';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Payment Mode *',
            value: state.paymentMode,
            items: ['Cash', 'Card', 'UPI', 'Bank Transfer'],
            onChanged: (v) =>
                context.read<CreateBillCubit>().updatePaymentMode(v!),
          ),
          if (state.pendingAmount > 0)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pending: ₹${state.pendingAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.tableRowBoldValue.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ===================== SUMMARY =====================
  Widget _buildSummary(BuildContext context, CreateBillState state) {
    return _buildCardWrapper(
      title: 'Bill Summary',
      icon: Icons.receipt_long,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Subtotal', '₹${state.subtotal.toStringAsFixed(2)}'),
          if (state.totalDiscount > 0)
            _buildSummaryRow(
              'Product Discounts',
              '- ₹${state.totalDiscount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          if (state.calculatedBillDiscount > 0)
            _buildSummaryRow(
              'Bill Discount',
              '- ₹${state.calculatedBillDiscount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          const Divider(height: 32, color: AppColors.divider),
          _buildSummaryRow(
            'Grand Total',
            '₹${state.grandTotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 24),
          _buildActionButtons(context, state),
        ],
      ),
    );
  }

  // ===================== MOBILE SUMMARY =====================
  Widget _buildMobileSummary(BuildContext context, CreateBillState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '₹${state.subtotal.toStringAsFixed(2)}'),
          if (state.totalDiscount > 0)
            _buildSummaryRow(
              'Product Discounts',
              '- ₹${state.totalDiscount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          if (state.calculatedBillDiscount > 0)
            _buildSummaryRow(
              'Bill Discount',
              '- ₹${state.calculatedBillDiscount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          const Divider(height: 20, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: AppTextStyles.tableRowBoldValue),
              Text(
                '₹${state.grandTotal.toStringAsFixed(2)}',
                style: AppTextStyles.tableRowBoldValue.copyWith(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButtons(context, state),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CreateBillState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check_circle, color: Colors.white),
            label: Text(
              state.isLoading ? 'Creating...' : 'Create Bill',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: state.isLoading || state.cartItems.isEmpty
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      context.read<CreateBillCubit>().createBill();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    _formKey.currentState?.reset();
                    context.read<CreateBillCubit>().clearBill();
                  },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===================== REUSABLE WIDGETS =====================
  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.customContainerTitle),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.tableRowBoldValue
                : AppTextStyles.tableRowNormal,
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.tableRowBoldValue.copyWith(fontSize: 18)
                : isDiscount
                ? AppTextStyles.tableRowRegular.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.tableRowRegular,
          ),
        ],
      ),
    );
  }

  // ===================== DATE PICKER =====================
  Future<void> _selectBillDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: context.read<CreateBillCubit>().state.billDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.secondary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      context.read<CreateBillCubit>().updateBillDate(picked);
    }
  }
}
// import 'package:billing_software/core/theme/app_colors.dart';
// import 'package:billing_software/core/theme/app_text_styles.dart';
// import 'package:billing_software/core/widgets/responsive_widget.dart';
// import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
// import 'package:billing_software/features/billing/presentation/cubit/create_bill_cubit.dart';
// import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
// import 'package:billing_software/features/products/domain/entity/product_model.dart';
// import 'package:billing_software/core/services/firebase.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:billing_software/core/utils/helpers.dart';

// class CreateBillPage extends StatefulWidget {
//   const CreateBillPage({super.key});

//   @override
//   State<CreateBillPage> createState() => _CreateBillPageState();
// }

// class _CreateBillPageState extends State<CreateBillPage> {
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<CreateBillCubit, CreateBillState>(
//       listener: (context, state) {
//         if (state.message != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.message!),
//               backgroundColor: state.message!.contains('success')
//                   ? AppColors.success
//                   : AppColors.error,
//             ),
//           );
//         }
//       },
//       child: BlocBuilder<CreateBillCubit, CreateBillState>(
//         builder: (context, state) {
//           return ResponsiveCustomBuilder(
//             mobileBuilder: (width) => _buildMobileLayout(context, state),
//             tabletBuilder: (width) => _buildTabletLayout(context, state),
//             desktopBuilder: (width) => _buildDesktopLayout(context, state),
//           );
//         },
//       ),
//     );
//   }

//   // ===================== MOBILE LAYOUT =====================
//   Widget _buildMobileLayout(BuildContext context, CreateBillState state) {
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildMobileHeader(),
//             const SizedBox(height: 16),
//             _buildProductSearch(context),
//             const SizedBox(height: 16),
//             _buildCartItems(context, state),
//             const SizedBox(height: 16),
//             _buildCustomerDetails(context, state),
//             const SizedBox(height: 16),
//             _buildPaymentDetails(context, state),
//             const SizedBox(height: 16),
//             _buildMobileSummary(context, state),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================== TABLET LAYOUT =====================
//   Widget _buildTabletLayout(BuildContext context, CreateBillState state) {
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             const SizedBox(height: 20),
//             _buildProductSearch(context),
//             const SizedBox(height: 20),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Column(children: [_buildCartItems(context, state)]),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       _buildCustomerDetails(context, state),
//                       const SizedBox(height: 20),
//                       _buildPaymentDetails(context, state),
//                       const SizedBox(height: 20),
//                       _buildSummary(context, state),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================== DESKTOP LAYOUT =====================
//   Widget _buildDesktopLayout(BuildContext context, CreateBillState state) {
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             const SizedBox(height: 24),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

//               child: _buildProductSearch(context),
//             ),
//             const SizedBox(height: 24),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(flex: 2, child: _buildCartItems(context, state)),
//                   const SizedBox(width: 24),
//                   Expanded(
//                     child: Column(
//                       children: [
//                         _buildCustomerDetails(context, state),
//                         const SizedBox(height: 20),
//                         _buildPaymentDetails(context, state),
//                         const SizedBox(height: 20),
//                         _buildSummary(context, state),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================== MOBILE HEADER =====================
//   Widget _buildMobileHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.secondary,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.add_shopping_cart, size: 24, color: AppColors.primary),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Create Bill',
//                   style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'Point of Sale',
//                   style: AppTextStyles.headerSubheading.copyWith(fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===================== HEADER =====================
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(24),

//       decoration: BoxDecoration(
//         color: AppColors.secondary,
//         border: Border(
//           top: BorderSide.none,
//           left: BorderSide.none,
//           right: BorderSide.none,
//           bottom: BorderSide(color: AppColors.blueGreyBorder),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.add_shopping_cart, size: 30, color: AppColors.primary),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Create Bill', style: AppTextStyles.headerHeading),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Point of Sale - Create new invoice',
//                   style: AppTextStyles.headerSubheading,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===================== PRODUCT SEARCH =====================
//   Widget _buildProductSearch(BuildContext context) {
//     return _buildCardWrapper(
//       title: 'Product Search',
//       icon: Icons.search,
//       child: BlocBuilder<CategoryCubit, CategoryState>(
//         builder: (context, categoryState) {
//           final categories = categoryState.categories;

//           return Autocomplete<ProductModel>(
//             optionsBuilder: (textEditingValue) async {
//               if (textEditingValue.text.isEmpty) {
//                 return const Iterable<ProductModel>.empty();
//               }
//               return await _searchProductsFromFirebase(textEditingValue.text);
//             },
//             displayStringForOption: (option) {
//               final categoryName = option.getCategoryName(categories);
//               return '${option.name} ($categoryName)';
//             },
//             onSelected: (selection) {
//               // Directly add to cart with quantity 1
//               context.read<CreateBillCubit>().addProductToCart(selection, 1);
//               final categoryName = selection.getCategoryName(categories);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     '${selection.name} ($categoryName) added to cart',
//                   ),
//                   backgroundColor: AppColors.success,
//                   duration: const Duration(seconds: 1),
//                 ),
//               );
//             },
//             optionsViewBuilder: (context, onSelected, options) {
//               return Align(
//                 alignment: Alignment.topLeft,
//                 child: Material(
//                   elevation: 4,
//                   borderRadius: BorderRadius.circular(8),
//                   child: Container(
//                     constraints: const BoxConstraints(maxHeight: 300),
//                     width: MediaQuery.of(context).size.width - 48,
//                     decoration: BoxDecoration(
//                       color: AppColors.secondary,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: AppColors.borderGrey),
//                     ),
//                     child: ListView.separated(
//                       padding: EdgeInsets.zero,
//                       shrinkWrap: true,
//                       separatorBuilder: (_, __) =>
//                           Divider(height: 1, color: AppColors.divider),
//                       itemCount: options.length,
//                       itemBuilder: (context, index) {
//                         final option = options.elementAt(index);
//                         final categoryName = option.getCategoryName(categories);

//                         return ListTile(
//                           onTap: () => onSelected(option),
//                           leading: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: AppColors.primary.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Icon(
//                               Icons.shopping_bag_outlined,
//                               size: 20,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                           title: Text(
//                             capitalizeWords(option.name),
//                             style: AppTextStyles.tableRowPrimary,
//                           ),
//                           subtitle: Text(
//                             categoryName,
//                             style: AppTextStyles.tableRowSecondary,
//                           ),
//                           trailing: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 '₹${option.price.toStringAsFixed(2)}',
//                                 style: AppTextStyles.tableRowBoldValue,
//                               ),
//                               Text(
//                                 'Stock: ${option.stockQty}',
//                                 style: AppTextStyles.tableRowSecondary.copyWith(
//                                   fontSize: 11,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               );
//             },
//             fieldViewBuilder: (context, controller, focusNode, _) {
//               return TextField(
//                 controller: controller,
//                 focusNode: focusNode,
//                 decoration: InputDecoration(
//                   hintText: 'Search by product name or scan barcode...',
//                   hintStyle: AppTextStyles.hintText,
//                   prefixIcon: Icon(
//                     CupertinoIcons.search,
//                     color: AppColors.textSecondary,
//                     size: 20,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: AppColors.borderGrey),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Future<List<ProductModel>> _searchProductsFromFirebase(String query) async {
//     try {
//       final lowercaseQuery = query.toLowerCase();
//       final nameQuery = await FBFireStore.products
//           .where('name', isGreaterThanOrEqualTo: lowercaseQuery)
//           .where('name', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
//           .limit(10)
//           .get();

//       final skuQuery = await FBFireStore.products
//           .where('sku', isGreaterThanOrEqualTo: lowercaseQuery)
//           .where('sku', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
//           .limit(10)
//           .get();

//       final List<ProductModel> results = [];
//       final Set<String> addedIds = {};

//       for (var doc in nameQuery.docs) {
//         if (addedIds.add(doc.id)) {
//           results.add(ProductModel.fromJson(doc.data(), doc.id));
//         }
//       }
//       for (var doc in skuQuery.docs) {
//         if (addedIds.add(doc.id)) {
//           results.add(ProductModel.fromJson(doc.data(), doc.id));
//         }
//       }
//       return results;
//     } catch (e) {
//       debugPrint('Error searching products: $e');
//       return [];
//     }
//   }

//   // ===================== CART ITEMS =====================
//   Widget _buildCartItems(BuildContext context, CreateBillState state) {
//     return _buildCardWrapper(
//       title: 'Cart Items',
//       icon: Icons.shopping_cart_outlined,
//       child: state.cartItems.isEmpty
//           ? Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(40),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.shopping_cart_outlined,
//                       size: 64,
//                       color: AppColors.borderGrey,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No items in cart',
//                       style: AppTextStyles.tableRowSecondary,
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           : ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               separatorBuilder: (_, __) =>
//                   Divider(height: 1, color: AppColors.divider),
//               itemCount: state.cartItems.length,
//               itemBuilder: (context, index) =>
//                   _buildCartItemRow(context, state.cartItems[index]),
//             ),
//     );
//   }

//   Widget _buildCartItemRow(BuildContext context, BillItemModel item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.productName, style: AppTextStyles.tableRowPrimary),
//                 const SizedBox(height: 4),
//                 Text(
//                   '₹${item.price.toStringAsFixed(2)} each',
//                   style: AppTextStyles.tableRowSecondary,
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.remove_circle_outline, size: 20),
//                 color: AppColors.textSecondary,
//                 onPressed: () => context
//                     .read<CreateBillCubit>()
//                     .updateItemQuantity(item.productId, item.quantity - 1),
//               ),
//               Text(
//                 '${item.quantity}',
//                 style: AppTextStyles.tableRowNormal.copyWith(
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.add_circle_outline, size: 20),
//                 color: AppColors.textSecondary,
//                 onPressed: () => context
//                     .read<CreateBillCubit>()
//                     .updateItemQuantity(item.productId, item.quantity + 1),
//               ),
//             ],
//           ),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 80,
//             child: Text(
//               '₹${item.itemTotal.toStringAsFixed(2)}',
//               style: AppTextStyles.tableRowBoldValue,
//               textAlign: TextAlign.right,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete_outline, size: 20),
//             color: AppColors.error,
//             onPressed: () => context.read<CreateBillCubit>().removeItemFromCart(
//               item.productId,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===================== CUSTOMER DETAILS =====================
//   Widget _buildCustomerDetails(BuildContext context, CreateBillState state) {
//     return _buildCardWrapper(
//       title: 'Customer Details *',
//       icon: Icons.person_outline,
//       child: Column(
//         children: [
//           TextFormField(
//             controller: context.read<CreateBillCubit>().customerNameController,
//             decoration: InputDecoration(
//               labelText: 'Customer Name *',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return 'Customer name is required';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: context.read<CreateBillCubit>().customerPhoneController,
//             decoration: InputDecoration(
//               labelText: 'Phone Number *',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             keyboardType: TextInputType.phone,
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return 'Phone number is required';
//               }
//               return null;
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ===================== PAYMENT DETAILS =====================
//   Widget _buildPaymentDetails(BuildContext context, CreateBillState state) {
//     return _buildCardWrapper(
//       title: 'Payment Details *',
//       icon: Icons.payments_outlined,
//       child: Column(
//         children: [
//           TextFormField(
//             controller: context
//                 .read<CreateBillCubit>()
//                 .amountReceivedController,
//             decoration: InputDecoration(
//               labelText: 'Amount Received (₹) *',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               suffixText: '₹',
//             ),
//             keyboardType: TextInputType.number,
//             onChanged: (value) {
//               final amount = double.tryParse(value) ?? 0;
//               context.read<CreateBillCubit>().updateAmountReceived(amount);
//             },
//             validator: (value) {
//               final amount = double.tryParse(value ?? '0') ?? 0;
//               if (amount <= 0) {
//                 return 'Amount must be greater than 0';
//               }
//               if (amount > state.grandTotal) {
//                 return 'Amount cannot exceed total (₹${state.grandTotal.toStringAsFixed(2)})';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           _buildDropdown(
//             label: 'Payment Mode *',
//             value: state.paymentMode,
//             items: ['Cash', 'Card', 'UPI', 'Bank Transfer'],
//             onChanged: (v) =>
//                 context.read<CreateBillCubit>().updatePaymentMode(v!),
//           ),
//           if (state.pendingAmount > 0)
//             Container(
//               margin: const EdgeInsets.only(top: 16),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppColors.warning.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: AppColors.warning),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.warning_amber, color: AppColors.warning),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Pending: ₹${state.pendingAmount.toStringAsFixed(2)}',
//                       style: AppTextStyles.tableRowBoldValue.copyWith(
//                         color: AppColors.warning,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ===================== SUMMARY =====================
//   Widget _buildSummary(BuildContext context, CreateBillState state) {
//     return _buildCardWrapper(
//       title: 'Bill Summary',
//       icon: Icons.receipt_long,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSummaryRow('Subtotal', '₹${state.subtotal.toStringAsFixed(2)}'),
//           const Divider(height: 32, color: AppColors.divider),
//           _buildSummaryRow(
//             'Grand Total',
//             '₹${state.grandTotal.toStringAsFixed(2)}',
//             isTotal: true,
//           ),
//           const SizedBox(height: 24),
//           _buildActionButtons(context, state),
//         ],
//       ),
//     );
//   }

//   // ===================== MOBILE SUMMARY =====================
//   Widget _buildMobileSummary(BuildContext context, CreateBillState state) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.secondary,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.borderGrey),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Total Amount', style: AppTextStyles.tableRowPrimary),
//               Text(
//                 '₹${state.grandTotal.toStringAsFixed(2)}',
//                 style: AppTextStyles.tableRowBoldValue.copyWith(fontSize: 20),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildActionButtons(context, state),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context, CreateBillState state) {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             icon: state.isLoading
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : const Icon(Icons.check_circle, color: Colors.white),
//             label: Text(
//               state.isLoading ? 'Creating...' : 'Create Bill',
//               style: GoogleFonts.inter(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             onPressed: state.isLoading || state.cartItems.isEmpty
//                 ? null
//                 : () {
//                     if (_formKey.currentState!.validate()) {
//                       context.read<CreateBillCubit>().createBill();
//                     }
//                   },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton(
//             onPressed: state.isLoading
//                 ? null
//                 : () {
//                     _formKey.currentState?.reset();
//                     context.read<CreateBillCubit>().clearBill();
//                   },
//             style: OutlinedButton.styleFrom(
//               side: BorderSide(color: AppColors.primary),
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'Clear All',
//               style: GoogleFonts.inter(
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ===================== REUSABLE WIDGETS =====================
//   Widget _buildCardWrapper({
//     required String title,
//     required IconData icon,
//     required Widget child,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.secondary,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.borderGrey),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: AppColors.primary, size: 22),
//               const SizedBox(width: 8),
//               Text(title, style: AppTextStyles.customContainerTitle),
//             ],
//           ),
//           const SizedBox(height: 16),
//           child,
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(
//     BuildContext context, {
//     required String label,
//     required TextEditingController controller,
//     required Function(String) onChanged,
//     TextInputType? keyboardType,
//     bool mandatory = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       keyboardType: keyboardType,
//       onChanged: onChanged,
//       validator: mandatory
//           ? (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return '$label is required';
//               }
//               return null;
//             }
//           : null,
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required String value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       items: items
//           .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
//           .toList(),
//       onChanged: onChanged,
//     );
//   }

//   Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: isTotal
//                 ? AppTextStyles.tableRowBoldValue
//                 : AppTextStyles.tableRowNormal,
//           ),
//           Text(
//             value,
//             style: isTotal
//                 ? AppTextStyles.tableRowBoldValue.copyWith(fontSize: 18)
//                 : AppTextStyles.tableRowRegular,
//           ),
//         ],
//       ),
//     );
//   }
// }
