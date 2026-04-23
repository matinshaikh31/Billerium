import 'package:billing_software/core/routes/routes.dart';
import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/pagination.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:billing_software/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billing_software/features/customer/presentation/cubit/customer_state.dart';
import 'package:billing_software/features/customer/presentation/widget/add_customer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().initializePagination();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
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
  Widget _buildMobileLayout(CustomerState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileHeader(),
          const SizedBox(height: 16),
          _buildMobileSearchFilter(),
          const SizedBox(height: 16),
          _buildMobileCustomersList(state),
        ],
      ),
    );
  }

  // ===================== TABLET LAYOUT =====================
  Widget _buildTabletLayout(CustomerState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildCustomersTable(context, state),
        ],
      ),
    );
  }

  // ===================== DESKTOP LAYOUT =====================
  Widget _buildDesktopLayout(CustomerState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildCustomersTable(context, state),
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
              Icon(Icons.people_outline, size: 24, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Customers',
                  style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddCustomerDialog(),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: Text(
                'Add Customer',
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
        border: Border(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(color: AppColors.blueGreyBorder),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline, size: 30, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customers', style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  'Manage your regular customers',
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddCustomerDialog(),
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: Text(
              'Add Customer',
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
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        return TextField(
          onChanged: (value) =>
              context.read<CustomerCubit>().searchCustomers(value),
          decoration: InputDecoration(
            hintText: 'Search by name or phone...',
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
        );
      },
    );
  }

  // ===================== MOBILE CUSTOMERS LIST =====================
  Widget _buildMobileCustomersList(CustomerState state) {
    if (state.isLoading && state.customers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.customers.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: state.customers.length,
          itemBuilder: (context, index) {
            return _buildMobileCustomerCard(state.customers[index]);
          },
        ),
        // Pagination removed for mobile - shows all loaded items
      ],
    );
  }

  // ===================== MOBILE CUSTOMER CARD =====================
  Widget _buildMobileCustomerCard(CustomerModel customer) {
    return InkWell(
      onTap: () => context.push(Routes.customerDetail, extra: customer),
      child: Container(
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : 'C',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name, style: AppTextStyles.tableRowPrimary),
                      const SizedBox(height: 4),
                      Text(
                        customer.phone,
                        style: AppTextStyles.tableRowSecondary,
                      ),
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

  // ===================== TABLE SECTION =====================
  Widget _buildCustomersTable(BuildContext context, CustomerState state) {
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
          if (state.isLoading && state.customers.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (state.customers.isEmpty)
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
                  itemCount: state.customers.length,
                  itemBuilder: (context, index) {
                    return _buildCustomerRow(state.customers[index]);
                  },
                ),
                if (state.searchQuery.isEmpty && state.totalPages > 1)
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
          flex: 3,
          child: TextField(
            onChanged: (value) =>
                context.read<CustomerCubit>().searchCustomers(value),
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
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
          ),
        ),
      ],
    );
  }

  // ===================== TABLE HEADERS =====================
  Widget _buildTableHeaders() {
    return Container(
      color: AppColors.headerBackground,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Customer', style: AppTextStyles.tabelHeader),
          ),
          SizedBox(
            width: 140,
            child: Text('Phone', style: AppTextStyles.tabelHeader),
          ),
          SizedBox(
            width: 120,
            child: Text('Balance', style: AppTextStyles.tabelHeader),
          ),
          SizedBox(
            width: 130,
            child: Text(
              'Total Sales',
              style: AppTextStyles.tabelHeader,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Orders',
              style: AppTextStyles.tabelHeader,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Actions',
              style: AppTextStyles.tabelHeader,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TABLE ROWS =====================
  Widget _buildCustomerRow(CustomerModel customer) {
    return InkWell(
      onTap: () => context.push(Routes.customerDetail, extra: customer),
      onHover: (hovering) {},
      hoverColor: AppColors.containerGreyColor.withValues(alpha: 0.3),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Customer with Avatar
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : 'C',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customer.name,
                      style: AppTextStyles.tableRowPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Phone
            SizedBox(
              width: 140,
              child: Text(
                customer.phone,
                style: AppTextStyles.tableRowSecondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Balance
            SizedBox(
              width: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: customer.hasDebt
                      ? AppColors.errorSoft
                      : customer.hasCredit
                      ? AppColors.successSoft
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '\u20b9${customer.balance.abs().toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: customer.hasDebt
                        ? AppColors.error
                        : customer.hasCredit
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            // Total Sales
            SizedBox(
              width: 130,
              child: Text(
                '\u20b9${customer.totalPurchases.toStringAsFixed(0)}',
                style: AppTextStyles.tableRowBoldValue,
                textAlign: TextAlign.right,
              ),
            ),
            // Orders
            SizedBox(
              width: 80,
              child: Text(
                '${customer.orderCount}',
                style: AppTextStyles.tableRowSecondary,
                textAlign: TextAlign.center,
              ),
            ),
            // Actions
            SizedBox(
              width: 80,
              child: Center(
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: AppColors.secondary,
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditCustomerDialog(customer);
                        break;
                      case 'delete':
                        _showDeleteDialog(customer);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    _buildPopupMenuItem(
                      'edit',
                      'Edit',
                      Icons.edit_outlined,
                      AppColors.primary,
                    ),
                    _buildPopupMenuItem(
                      'delete',
                      'Delete',
                      Icons.delete_outline,
                      AppColors.error,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== POPUP MENU ITEM =====================
  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
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
            Icon(Icons.people_outline, size: 64, color: AppColors.borderGrey),
            const SizedBox(height: 16),
            Text('No customers found', style: AppTextStyles.tableRowPrimary),
          ],
        ),
      ),
    );
  }

  // ===================== PAGINATION =====================
  Widget _buildPagination(BuildContext context, CustomerState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: DynamicPagination(
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        onPageChanged: (page) {
          final isNextPage = page > state.currentPage;
          context.read<CustomerCubit>().goToPage(page, isNextPage: isNextPage);
        },
      ),
    );
  }

  // ===================== ADD CUSTOMER DIALOG =====================
  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCustomerDialog(),
    ).then((_) {
      // Refresh list after dialog closes
      context.read<CustomerCubit>().initializePagination();
    });
  }

  // ===================== EDIT CUSTOMER DIALOG =====================
  void _showEditCustomerDialog(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => AddCustomerDialog(customer: customer),
    ).then((_) {
      // Refresh list after dialog closes
      context.read<CustomerCubit>().initializePagination();
    });
  }

  // ===================== DELETE CONFIRMATION DIALOG =====================
  void _showDeleteDialog(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Delete Customer', style: AppTextStyles.dialogHeading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this customer?',
              style: AppTextStyles.tableRowPrimary,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${customer.name}',
                    style: AppTextStyles.tableRowSecondary,
                  ),
                  Text(
                    'Phone: ${customer.phone}',
                    style: AppTextStyles.tableRowSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.tableRowSecondary),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CustomerCubit>().deleteCustomer(customer.id);
            },
            child: Text(
              'Delete',
              style: AppTextStyles.tableRowPrimary.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
