import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_cubit.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_state.dart';
import 'package:billing_software/features/purchase/presentation/page/create_purchase_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PurchaseCubit>().fetchPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseCubit, PurchaseState>(
      builder: (context, state) {
        return ResponsiveCustomBuilder(
          mobileBuilder: (width) => _buildMobileLayout(state),
          tabletBuilder: (width) => _buildDesktopLayout(state),
          desktopBuilder: (width) => _buildDesktopLayout(state),
        );
      },
    );
  }

  // ===================== MOBILE LAYOUT =====================
  Widget _buildMobileLayout(PurchaseState state) {
    return Column(
      children: [
        _buildMobileHeader(),
        Expanded(child: _buildPurchasesList(state)),
      ],
    );
  }

  // ===================== DESKTOP LAYOUT =====================
  Widget _buildDesktopLayout(PurchaseState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildPurchasesTable(context, state),
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
                Icons.shopping_bag_outlined,
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Purchases',
                  style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreatePurchaseDialog(context),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: Text(
                'New Purchase',
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
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border(bottom: BorderSide(color: AppColors.blueGreyBorder)),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 30, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Purchases', style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  'Track your inventory purchases',
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreatePurchaseDialog(context),
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: Text(
              'New Purchase',
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

  // ===================== PURCHASES TABLE =====================
  Widget _buildPurchasesTable(BuildContext context, PurchaseState state) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<PurchaseCubit>().fetchPurchases();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.purchases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No purchases yet',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click "New Purchase" to add your first purchase',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blueGreyBorder),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              border: Border(
                bottom: BorderSide(color: AppColors.blueGreyBorder),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Purchase No', style: AppTextStyles.tabelHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Supplier', style: AppTextStyles.tabelHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Date', style: AppTextStyles.tabelHeader),
                ),
                Expanded(
                  flex: 1,
                  child: Text('Items', style: AppTextStyles.tabelHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: AppTextStyles.tabelHeader,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.purchases.length,
            itemBuilder: (context, index) {
              final purchase = state.purchases[index];
              final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.blueGreyBorder.withOpacity(0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        purchase.purchaseNo,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        purchase.supplierName ?? 'N/A',
                        style: AppTextStyles.tableRowNormal,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        dateFormat.format(purchase.createdAt.toDate()),
                        style: AppTextStyles.tableRowDate,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${purchase.items.length}',
                        style: AppTextStyles.tableRowNormal,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '₹${purchase.finalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===================== MOBILE PURCHASES LIST =====================
  Widget _buildPurchasesList(PurchaseState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<PurchaseCubit>().fetchPurchases();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.purchases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No purchases yet',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.purchases.length,
      itemBuilder: (context, index) {
        final purchase = state.purchases[index];
        final dateFormat = DateFormat('dd MMM yyyy');

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      purchase.purchaseNo,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '₹${purchase.finalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (purchase.supplierName != null)
                  Text(
                    'Supplier: ${purchase.supplierName}',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                Text(
                  'Date: ${dateFormat.format(purchase.createdAt.toDate())}',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                Text(
                  'Items: ${purchase.items.length}',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== SHOW CREATE PURCHASE DIALOG =====================
  void _showCreatePurchaseDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePurchasePage()),
    );
  }
}
