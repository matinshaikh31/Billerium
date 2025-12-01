import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/features/purchase/domain/entity/purchase_item_model.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_form_cubit.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPurchaseItemDialog extends StatefulWidget {
  const AddPurchaseItemDialog({super.key});

  @override
  State<AddPurchaseItemDialog> createState() => _AddPurchaseItemDialogState();
}

class _AddPurchaseItemDialogState extends State<AddPurchaseItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  ProductModel? _selectedProduct;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Dialog(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isDesktop ? 500 : size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isDesktop),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductDropdown(),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _quantityController,
                        label: "Quantity *",
                        hint: "Enter quantity",
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter quantity';
                          }
                          final qty = int.tryParse(value);
                          if (qty == null || qty <= 0) {
                            return 'Please enter valid quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _priceController,
                        label: "Purchase Price *",
                        hint: "Enter purchase price",
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefix: "₹",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter purchase price';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Please enter valid price';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLarge) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border(bottom: BorderSide(color: AppColors.blueGreyBorder)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.add_circled_solid,
              color: AppColors.primary,
              size: isLarge ? 22 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add Purchase Item',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: isLarge ? 18 : 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.textSecondary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Product *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<ProductModel>(
          optionsBuilder: (textEditingValue) async {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<ProductModel>.empty();
            }
            return await _searchProductsFromFirebase(textEditingValue.text);
          },
          displayStringForOption: (option) => option.name,
          onSelected: (selection) {
            setState(() {
              _selectedProduct = selection;
            });
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  width: 450,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final product = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(product),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.borderGrey.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Stock: ${product.stockQty}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Price: ₹${product.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
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
              ),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, _) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Search by product name or SKU...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.containerGreyColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.8,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1.8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (_selectedProduct == null) {
                  return 'Please search and select a product';
                }
                return null;
              },
            );
          },
        ),
        if (_selectedProduct != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${_selectedProduct!.name}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark, size: 18),
                  color: AppColors.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _selectedProduct = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? prefix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            prefixText: prefix,
            prefixStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            filled: true,
            fillColor: AppColors.containerGreyColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.8,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border(top: BorderSide(color: AppColors.blueGreyBorder)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderGrey),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleAddItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Item',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddItem() {
    if (_formKey.currentState?.validate() ?? false) {
      final quantity = int.parse(_quantityController.text.trim());
      final price = double.parse(_priceController.text.trim());

      final item = PurchaseItemModel(
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        quantity: quantity,
        purchasePrice: price,
        total: quantity * price,
      );

      context.read<PurchaseFormCubit>().addItem(item);
      Navigator.pop(context);
    }
  }
}
