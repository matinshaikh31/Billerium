
import 'package:billing_software/features/billing2/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing2/presentation/cubit/create_bill_cubit.dart';
import 'package:billing_software/features/products3/domain/entity/product_model.dart';
import 'package:billing_software/features/products3/presentation/cubit/product_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateBillPage extends StatefulWidget {
  const CreateBillPage({super.key});

  @override
  State<CreateBillPage> createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateBillCubit, CreateBillState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.message!.contains('success') ? Colors.green : Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<CreateBillCubit, CreateBillState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildProductSearch(context),
                          const SizedBox(height: 20),
                          _buildCartItems(context, state),
                          const SizedBox(height: 20),
                          _buildCustomerDetails(context, state),
                          const SizedBox(height: 20),
                          _buildPaymentDetails(context, state),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildSummary(context, state),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Bill',
          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Point of Sale - Create new invoice',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProductSearch(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Product Search',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, productState) {
              return Autocomplete<ProductModel>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<ProductModel>.empty();
                  }
                  return productState.filteredProducts.where((product) {
                    return product.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                        (product.sku?.toLowerCase().contains(textEditingValue.text.toLowerCase()) ?? false);
                  });
                },
                displayStringForOption: (ProductModel option) => option.name,
                onSelected: (ProductModel selection) {
                  _showQuantityDialog(context, selection);
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search by product name or scan barcode...',
                      prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, CreateBillState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cart Items',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (state.cartItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No items in cart',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: state.cartItems.length,
              itemBuilder: (context, index) {
                final item = state.cartItems[index];
                return _buildCartItemRow(context, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(BuildContext context, BillItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.price} | Disc: ${item.discountPercent}%',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () {
                  context.read<CreateBillCubit>().updateItemQuantity(item.productId, item.quantity - 1);
                },
              ),
              Text(
                '${item.quantity}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () {
                  context.read<CreateBillCubit>().updateItemQuantity(item.productId, item.quantity + 1);
                },
              ),
            ],
          ),
          SizedBox(
            width: 80,
            child: Text(
              '₹${item.itemTotal.toStringAsFixed(0)}',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            onPressed: () {
              context.read<CreateBillCubit>().removeItemFromCart(item.productId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(BuildContext context, CreateBillState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Details (Optional)',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: context.read<CreateBillCubit>().customerNameController,
            decoration: InputDecoration(
              labelText: 'Customer Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) => context.read<CreateBillCubit>().updateCustomerName(value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: context.read<CreateBillCubit>().customerPhoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => context.read<CreateBillCubit>().updateCustomerPhone(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(BuildContext context, CreateBillState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: context.read<CreateBillCubit>().amountReceivedController,
            decoration: InputDecoration(
              labelText: 'Amount Received (₹)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              context.read<CreateBillCubit>().updateAmountReceived(double.tryParse(value) ?? 0);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.paymentMode,
            decoration: InputDecoration(
              labelText: 'Payment Mode',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: ['Cash', 'Card', 'UPI', 'Net Banking'].map((mode) {
              return DropdownMenuItem(value: mode, child: Text(mode));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<CreateBillCubit>().updatePaymentMode(value);
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.paymentStatus,
            decoration: InputDecoration(
              labelText: 'Payment Status',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: ['Pending', 'Paid', 'Partially Paid'].map((status) {
              return DropdownMenuItem(value: status, child: Text(status));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<CreateBillCubit>().updatePaymentStatus(value);
              }
            },
          ),
          if (state.pendingAmount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Pending Amount: ₹${state.pendingAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[900],
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

  Widget _buildSummary(BuildContext context, CreateBillState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Cart Items: ${state.cartItems.length}',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildSummaryRow('Subtotal', '₹${state.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Bill Discount', '-₹${state.billDiscountAmount.toStringAsFixed(2)}', isDiscount: true),
          const Divider(height: 24),
          _buildSummaryRow(
            'Grand Total',
            '₹${state.grandTotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 24),
          _buildBillDiscount(context, state),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading || state.cartItems.isEmpty
                  ? null
                  : () => context.read<CreateBillCubit>().createBill(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long),
                        const SizedBox(width: 8),
                        Text(
                          'Save & Print Invoice',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.isLoading ? null : () => context.read<CreateBillCubit>().clearBill(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isDiscount ? Colors.red : null,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFF3B82F6) : (isDiscount ? Colors.red : null),
          ),
        ),
      ],
    );
  }

  Widget _buildBillDiscount(BuildContext context, CreateBillState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill Discount',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: context.read<CreateBillCubit>().billDiscountController,
                decoration: InputDecoration(
                  labelText: 'Discount Value',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  context.read<CreateBillCubit>().updateBillDiscount(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: state.billDiscountType,
              items: ['Percentage', 'Amount'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text('${type == 'Percentage' ? '%' : '₹'}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<CreateBillCubit>().updateBillDiscountType(value);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showQuantityDialog(BuildContext context, ProductModel product) {
    final quantityController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add ${product.name}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: quantityController,
          decoration: InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 1;
              context.read<CreateBillCubit>().addProductToCart(product, quantity);
              Navigator.pop(dialogContext);
            },
            child: Text('Add to Cart', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }
}
