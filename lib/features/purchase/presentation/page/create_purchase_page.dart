import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/features/purchase/domain/entity/purchase_item_model.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_form_cubit.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_form_state.dart';
import 'package:billing_software/features/purchase/presentation/widget/add_purchase_item_dialog.dart';
import 'package:billing_software/features/products/presentation/cubit/product_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePurchasePage extends StatefulWidget {
  const CreatePurchasePage({super.key});

  @override
  State<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends State<CreatePurchasePage> {
  final _supplierNameController = TextEditingController();
  final _supplierPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().initializeProductsPagination();
    context.read<PurchaseFormCubit>().reset();
  }

  @override
  void dispose() {
    _supplierNameController.dispose();
    _supplierPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<PurchaseFormCubit, PurchaseFormState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildHeader(context, isDesktop),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 28 : (isTablet ? 24 : 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSupplierSection(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 28 : 20),
                    _buildItemsSection(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 28 : 20),
                    _buildTotalsSection(isDesktop, isTablet),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLarge) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border(bottom: BorderSide(color: AppColors.blueGreyBorder)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.shopping_cart,
              color: AppColors.primary,
              size: isLarge ? 24 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Create New Purchase',
              style: GoogleFonts.inter(
                fontSize: isLarge ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.xmark_circle_fill),
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierSection(bool isDesktop, bool isTablet) {
    final isMobile = !isDesktop && !isTablet;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueGreyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: CupertinoIcons.person_fill,
            iconColor: AppColors.primary,
            title: "Supplier Information (Optional)",
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (isMobile) ...[
            _buildTextField(
              controller: _supplierNameController,
              label: "Supplier Name",
              hint: "e.g., ABC Suppliers",
              onChanged: (value) {
                context.read<PurchaseFormCubit>().setSupplierName(value);
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _supplierPhoneController,
              label: "Supplier Phone",
              hint: "e.g., 9876543210",
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                context.read<PurchaseFormCubit>().setSupplierPhone(value);
              },
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _supplierNameController,
                    label: "Supplier Name",
                    hint: "e.g., ABC Suppliers",
                    onChanged: (value) {
                      context.read<PurchaseFormCubit>().setSupplierName(value);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildTextField(
                    controller: _supplierPhoneController,
                    label: "Supplier Phone",
                    hint: "e.g., 9876543210",
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      context.read<PurchaseFormCubit>().setSupplierPhone(value);
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(bool isDesktop, bool isTablet) {
    final isMobile = !isDesktop && !isTablet;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueGreyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(
                icon: CupertinoIcons.cube_box_fill,
                iconColor: AppColors.documentBtn,
                title: "Purchase Items",
                isMobile: isMobile,
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddItemDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Add Item',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<PurchaseFormCubit, PurchaseFormState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.cube_box,
                          size: 48,
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No items added yet',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _buildItemCard(item, index, isMobile);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(PurchaseItemModel item, int index, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.containerGreyColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} × ₹${item.purchasePrice.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.total.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(CupertinoIcons.delete, size: 20),
            color: Colors.red,
            onPressed: () {
              context.read<PurchaseFormCubit>().removeItem(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection(bool isDesktop, bool isTablet) {
    final isMobile = !isDesktop && !isTablet;

    return BlocBuilder<PurchaseFormCubit, PurchaseFormState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blueGreyBorder),
          ),
          child: Column(
            children: [
              _buildTotalRow('Subtotal', state.subtotal),
              const SizedBox(height: 12),
              _buildTotalRow('Tax', state.totalTax),
              const Divider(height: 24),
              _buildTotalRow('Total Amount', state.finalAmount, isTotal: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.green[700] : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDesktop) {
    return BlocBuilder<PurchaseFormCubit, PurchaseFormState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            border: Border(top: BorderSide(color: AppColors.blueGreyBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isLoading
                      ? null
                      : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderGrey),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: state.isLoading || state.items.isEmpty
                      ? null
                      : () async {
                          await context
                              .read<PurchaseFormCubit>()
                              .submitPurchase();
                          if (context.mounted &&
                              !state.isLoading &&
                              state.error == null) {
                            Navigator.pop(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                          'Create Purchase',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isMobile,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: iconColor, size: isMobile ? 18 : 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
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
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const AddPurchaseItemDialog(),
    );
  }
}
