import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/presentation/cubit/edit_bill_cubit.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/core/services/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billing_software/core/utils/helpers.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class EditBillPage extends StatefulWidget {
  final BillModel bill;

  const EditBillPage({super.key, required this.bill});

  @override
  State<EditBillPage> createState() => _EditBillPageState();
}

class _EditBillPageState extends State<EditBillPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load the bill into the cubit with categories to enrich category data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = context.read<CategoryCubit>().state.categories;
      context.read<EditBillCubit>().loadBill(widget.bill, categories);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text(
          'Edit Bill #${widget.bill.billNo}',
          style: AppTextStyles.customContainerTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<EditBillCubit, EditBillState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.isSuccess
                    ? AppColors.success
                    : AppColors.error,
              ),
            );
          }
          if (state.isSuccess) {
            context.pop(true); // Return true to indicate bill was updated
          }
        },
        child: BlocBuilder<EditBillCubit, EditBillState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ResponsiveCustomBuilder(
              mobileBuilder: (width) => _buildMobileLayout(context, state),
              tabletBuilder: (width) => _buildTabletLayout(context, state),
              desktopBuilder: (width) => _buildDesktopLayout(context, state),
            );
          },
        ),
      ),
    );
  }

  // ===================== MOBILE LAYOUT =====================
  Widget _buildMobileLayout(BuildContext context, EditBillState state) {
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
          Icon(Icons.edit_note, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Bill #${widget.bill.billNo}',
                  style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  'Modify bill details',
                  style: AppTextStyles.headerSubheading.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          _buildBillDatePicker(context),
        ],
      ),
    );
  }

  // ===================== TABLET LAYOUT =====================
  Widget _buildTabletLayout(BuildContext context, EditBillState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildProductSearch(context),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildCartItems(context, state)),
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
                        _buildSummaryCard(context, state),
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

  // ===================== DESKTOP LAYOUT =====================
  Widget _buildDesktopLayout(BuildContext context, EditBillState state) {
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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildCartItems(context, state)),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildCustomerDetails(context, state),
                        const SizedBox(height: 20),
                        _buildBillDiscount(context, state),
                        const SizedBox(height: 20),
                        _buildPaymentDetails(context, state),
                        const SizedBox(height: 20),
                        _buildSummaryCard(context, state),
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
          Icon(Icons.edit_note, size: 30, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Bill #${widget.bill.billNo}',
                  style: AppTextStyles.headerHeading,
                ),
                const SizedBox(height: 4),
                Text(
                  'Modify bill details and items',
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
          _buildBillDatePicker(context),
        ],
      ),
    );
  }

  // ===================== BILL DATE PICKER =====================
  Widget _buildBillDatePicker(BuildContext context) {
    final cubit = context.read<EditBillCubit>();
    return BlocBuilder<EditBillCubit, EditBillState>(
      builder: (context, state) {
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: state.billDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              cubit.updateBillDate(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textSecondary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(state.billDate),
                  style: AppTextStyles.tableRowPrimary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== PRODUCT SEARCH =====================
  Widget _buildProductSearch(BuildContext context) {
    final categories = context.watch<CategoryCubit>().state.categories;

    return _buildCardWrapper(
      title: 'Product Search',
      icon: Icons.search,
      child: Autocomplete<ProductModel>(
        displayStringForOption: (product) => product.name,
        optionsBuilder: (textEditingValue) async {
          if (textEditingValue.text.isEmpty) return [];
          final snapshot = await FBFireStore.products
              .where(
                'name',
                isGreaterThanOrEqualTo: textEditingValue.text.toLowerCase(),
              )
              .where(
                'name',
                isLessThanOrEqualTo:
                    '${textEditingValue.text.toLowerCase()}\uf8ff',
              )
              .limit(10)
              .get();
          return snapshot.docs
              .map((doc) => ProductModel.fromDocSnap(doc))
              .toList();
        },
        onSelected: (product) {
          final categoryName = product.getCategoryName(categories);
          context.read<EditBillCubit>().addProductToCart(
            product,
            1,
            categoryName: categoryName,
          );
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Search products to add...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              // fillColor: AppColors.primary,
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
                width: 400,
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final product = options.elementAt(index);
                    final categoryName = product.getCategoryName(categories);
                    return ListTile(
                      title: Text(capitalizeWords(product.name)),
                      subtitle: Text(
                        '$categoryName • ₹${product.finalPrice.toStringAsFixed(2)}',
                      ),
                      trailing: Text('Stock: ${product.stockQty}'),
                      onTap: () => onSelected(product),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===================== CART ITEMS =====================
  Widget _buildCartItems(BuildContext context, EditBillState state) {
    return _buildCardWrapper(
      title: 'Cart Items',
      icon: Icons.shopping_cart_outlined,
      child: state.cartItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No items in cart',
                      style: AppTextStyles.tableRowSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search and add products above',
                      style: AppTextStyles.tableRowSecondary.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.cartItems.length} items',
                      style: AppTextStyles.tableRowSecondary,
                    ),
                    Text(
                      'Subtotal: ₹${state.subtotal.toStringAsFixed(2)}',
                      style: AppTextStyles.tableRowBoldValue,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                ...state.cartItems.map(
                  (item) => _buildCartItemRow(context, item),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItemRow(BuildContext context, BillItemModel item) {
    final cubit = context.read<EditBillCubit>();
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
                  Text(
                    '₹${item.price.toStringAsFixed(2)} (-${item.discountPercent.toStringAsFixed(0)}%)',
                    style: AppTextStyles.tableRowSecondary.copyWith(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 11,
                    ),
                  ),
                ] else ...[
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: AppTextStyles.tableRowSecondary,
                  ),
                ],
              ],
            ),
          ),
          // Quantity controls
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () =>
                    cubit.updateItemQuantity(item.productId, item.quantity - 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '${item.quantity}',
                  style: AppTextStyles.tableRowPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () =>
                    cubit.updateItemQuantity(item.productId, item.quantity + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Item total
          SizedBox(
            width: 80,
            child: Text(
              '₹${item.itemTotal.toStringAsFixed(2)}',
              style: AppTextStyles.tableRowBoldValue,
              textAlign: TextAlign.right,
            ),
          ),
          // Remove button
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () => cubit.removeItemFromCart(item.productId),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  // ===================== CUSTOMER DETAILS =====================
  Widget _buildCustomerDetails(BuildContext context, EditBillState state) {
    final cubit = context.read<EditBillCubit>();
    return _buildCardWrapper(
      title: 'Customer Details',
      icon: Icons.person_outline,
      child: Column(
        children: [
          TextFormField(
            controller: cubit.customerNameController,
            decoration: InputDecoration(
              labelText: 'Customer Name *',
              hintText: 'Enter customer name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              // fillColor: AppColors.primary,
            ),
            onChanged: cubit.updateCustomerName,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter customer name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: cubit.customerPhoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              // fillColor: AppColors.primary,
            ),
            keyboardType: TextInputType.phone,
            onChanged: cubit.updateCustomerPhone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: cubit.customerGstController,
            decoration: InputDecoration(
              labelText: 'Customer GST Number',
              hintText: 'e.g., 22AAAAA0000A1Z5',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              // fillColor: AppColors.primary,
            ),
            onChanged: cubit.updateCustomerGstNumber,
          ),
        ],
      ),
    );
  }

  // ===================== BILL DISCOUNT =====================
  Widget _buildBillDiscount(BuildContext context, EditBillState state) {
    final cubit = context.read<EditBillCubit>();
    return _buildCardWrapper(
      title: 'Bill Discount (Optional)',
      icon: Icons.discount_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: cubit.billDiscountPercentController,
            decoration: InputDecoration(
              labelText: 'Discount Percentage',
              hintText: 'Enter discount %',
              suffixText: '%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              // fillColor: AppColors.primary,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final percent = double.tryParse(value) ?? 0;
              cubit.updateBillDiscountPercent(percent);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: cubit.billDiscountAmountController,
            decoration: InputDecoration(
              labelText: 'Discount Amount',
              hintText: 'Enter discount amount',
              prefixText: '₹ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              // fillColor: AppColors.primary,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final amount = double.tryParse(value) ?? 0;
              cubit.updateBillDiscountAmount(amount);
            },
          ),
          if (state.calculatedBillDiscount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Bill Discount',
                    style: AppTextStyles.tableRowSecondary,
                  ),
                  Text(
                    '- ₹${state.calculatedBillDiscount.toStringAsFixed(2)}',
                    style: AppTextStyles.tableRowBoldValue.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===================== PAYMENT DETAILS =====================
  Widget _buildPaymentDetails(BuildContext context, EditBillState state) {
    final cubit = context.read<EditBillCubit>();
    return _buildCardWrapper(
      title: 'Payment Details *',
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: cubit.amountReceivedController,
            decoration: InputDecoration(
              labelText: 'Amount Received',
              hintText: 'Enter amount received',
              prefixText: '₹ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              // fillColor: AppColors.primary,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final amount = double.tryParse(value) ?? 0;
              cubit.updateAmountReceived(amount);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount received';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.paymentMode,
            decoration: InputDecoration(
              labelText: 'Payment Mode',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              // fillColor: AppColors.primary,
            ),
            items: ['Cash', 'Card', 'UPI', 'Bank Transfer', 'Credit']
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                .toList(),
            onChanged: (value) {
              if (value != null) cubit.updatePaymentMode(value);
            },
          ),
        ],
      ),
    );
  }

  // ===================== SUMMARY CARD =====================
  Widget _buildSummaryCard(BuildContext context, EditBillState state) {
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
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Amount Received',
            '₹${state.amountReceived.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Pending Amount',
            '₹${state.pendingAmount.toStringAsFixed(2)}',
            isTotal: true,
            color: state.pendingAmount > 0
                ? AppColors.error
                : AppColors.success,
          ),
          const SizedBox(height: 16),
          _buildActionButtons(context, state),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, EditBillState state) {
    final cubit = context.read<EditBillCubit>();
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
              state.isLoading ? 'Updating...' : 'Update Bill',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: state.isLoading || state.cartItems.isEmpty
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      cubit.saveBill();
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
            onPressed: state.isLoading ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
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

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
    Color? color,
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
            style:
                (isTotal
                        ? AppTextStyles.tableRowBoldValue
                        : AppTextStyles.tableRowNormal)
                    .copyWith(color: isDiscount ? AppColors.success : color),
          ),
        ],
      ),
    );
  }

  // ===================== MOBILE SUMMARY =====================
  Widget _buildMobileSummary(BuildContext context, EditBillState state) {
    return _buildSummaryCard(context, state);
  }
}
