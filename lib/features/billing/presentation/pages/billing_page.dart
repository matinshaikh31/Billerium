import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../products/domain/models/product_model.dart';
import '../cubit/billing_cubit.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final _searchController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _billDiscountController = TextEditingController();
  final _amountPaidController = TextEditingController();
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String _paymentMode = 'Cash';

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _billDiscountController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final productState = context.read<ProductCubit>().state;
    final results = productState.products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          (product.sku?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              // Navigate to bills list
            },
            tooltip: 'View Bills',
          ),
        ],
      ),
      drawer: ResponsiveHelper.isMobile(context) ? const AppDrawer() : null,
      body: BlocConsumer<BillingCubit, BillingState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget(message: 'Processing...');
          }

          return ResponsiveWidget(
            mobile: _buildMobileLayout(),
            desktop: Row(
              children: [
                const SizedBox(width: 250, child: AppDrawer()),
                Expanded(child: _buildDesktopLayout()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildCartSection()),
        const VerticalDivider(width: 1),
        Expanded(child: _buildSummarySection()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(child: _buildCartSection()),
        _buildSummarySection(),
      ],
    );
  }

  Widget _buildCartSection() {
    return BlocBuilder<BillingCubit, BillingState>(
      builder: (context, state) {
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _searchProducts,
                    decoration: InputDecoration(
                      hintText: 'Search products by name or barcode...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchProducts('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_isSearching && _searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final product = _searchResults[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                              'Stock: ${product.stockQty} | ₹${product.price}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                context.read<BillingCubit>().addToCart(product);
                                _searchController.clear();
                                _searchProducts('');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            // Cart Items
            Expanded(
              child: state.cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Cart is empty',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Search and add products to create a bill',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = state.cartItems[index];
                        final itemTotal = item.price * item.quantity;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.productName),
                            subtitle: Text('₹${item.price} x ${item.quantity}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    context
                                        .read<BillingCubit>()
                                        .updateCartItemQuantity(
                                          item.productId,
                                          item.quantity - 1,
                                        );
                                  },
                                ),
                                Text(
                                  '₹${CurrencyFormatter.format(itemTotal)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    context
                                        .read<BillingCubit>()
                                        .updateCartItemQuantity(
                                          item.productId,
                                          item.quantity + 1,
                                        );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  onPressed: () {
                                    context.read<BillingCubit>().removeFromCart(
                                      item.productId,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummarySection() {
    return BlocBuilder<BillingCubit, BillingState>(
      builder: (context, state) {
        final subtotal = state.calculations['subtotal'] ?? 0.0;
        final totalDiscount = state.calculations['totalDiscount'] ?? 0.0;
        final totalTax = state.calculations['totalTax'] ?? 0.0;
        final finalAmount = state.calculations['finalAmount'] ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    context.read<BillingCubit>().setCustomerInfo(
                      value,
                      _customerPhoneController.text,
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customerPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    context.read<BillingCubit>().setCustomerInfo(
                      _customerNameController.text,
                      value,
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Bill Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Subtotal', subtotal),
                _buildSummaryRow('Discount', totalDiscount, isNegative: true),
                _buildSummaryRow('Tax', totalTax),
                const Divider(),
                _buildSummaryRow(
                  'Total',
                  finalAmount,
                  isBold: true,
                  fontSize: 20,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _billDiscountController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Discount (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final discount = double.tryParse(value) ?? 0;
                    context.read<BillingCubit>().setBillDiscount(
                      percent: discount,
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMode,
                  decoration: const InputDecoration(
                    labelText: 'Payment Mode',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Cash', 'Card', 'UPI', 'Other']
                      .map(
                        (mode) =>
                            DropdownMenuItem(value: mode, child: Text(mode)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _paymentMode = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountPaidController,
                  decoration: const InputDecoration(
                    labelText: 'Amount Paid',
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.cartItems.isEmpty
                        ? null
                        : () {
                            final amountPaid =
                                double.tryParse(_amountPaidController.text) ??
                                finalAmount;
                            context.read<BillingCubit>().createBill(
                              amountPaid: amountPaid,
                              paymentMode: _paymentMode,
                            );
                            // Clear form
                            _customerNameController.clear();
                            _customerPhoneController.clear();
                            _billDiscountController.clear();
                            _amountPaidController.clear();
                            setState(() => _paymentMode = 'Cash');
                          },
                    child: const Text(
                      'Create Bill',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isNegative = false,
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}₹${CurrencyFormatter.format(amount)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isNegative ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
