import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/core/widgets/pagination.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:billing_software/features/customer/domain/entity/monthly_customer_analytics_model.dart';
import 'package:billing_software/features/customer/data/firebase_customer_analytics_repository.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:billing_software/core/services/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomerDetailPage extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final FirebaseCustomerAnalyticsRepository _analyticsRepo =
      FirebaseCustomerAnalyticsRepository();
  final int _pageSize = 10;

  List<BillModel> _bills = [];
  List<TransactionModel> _transactions = [];
  List<MonthlyCustomerAnalyticsModel> _monthlyAnalytics = [];
  bool _isLoading = true;
  String _selectedView = 'overview'; // overview, bills, transactions

  // Pagination state for bills
  int _billsCurrentPage = 1;
  int _billsTotalPages = 1;
  DocumentSnapshot? _billsLastDoc;
  DocumentSnapshot? _billsFirstDoc;

  // Pagination state for transactions
  int _transactionsCurrentPage = 1;
  int _transactionsTotalPages = 1;
  DocumentSnapshot? _transactionsLastDoc;
  DocumentSnapshot? _transactionsFirstDoc;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBills();
    _loadTransactions();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load customer transactions
      final transactionsSnapshot = await FBFireStore.transactions
          .where('customerId', isEqualTo: widget.customer.id)
          .orderBy('timestamp', descending: true)
          .get();

      final transactions = transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
          .toList();

      // Load monthly analytics
      final monthlyAnalytics = await _analyticsRepo.getMonthlyAnalytics(
        widget.customer.id,
      );

      setState(() {
        _transactions = transactions;
        _monthlyAnalytics = monthlyAnalytics;
        _isLoading = false;
      });
    } catch (e) {
      // Error loading customer data
      setState(() => _isLoading = false);
    }
  }

  // Load bills with pagination
  Future<void> _loadBills({int page = 1}) async {
    try {
      // Calculate total pages
      final totalBillsSnapshot = await FBFireStore.bills
          .where('customerId', isEqualTo: widget.customer.id)
          .get();
      final totalPages = (totalBillsSnapshot.size / _pageSize).ceil();

      Query query = FBFireStore.bills
          .where('customerId', isEqualTo: widget.customer.id)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (page > 1 && _billsLastDoc != null) {
        query = query.startAfterDocument(_billsLastDoc!);
      }

      final snapshot = await query.get();
      final bills = snapshot.docs
          .map(
            (doc) => BillModel.fromDocSnap(
              doc as QueryDocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();

      setState(() {
        _bills = bills;
        _billsCurrentPage = page;
        _billsTotalPages = totalPages > 0 ? totalPages : 1;
        _billsLastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _billsFirstDoc = snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
      });
    } catch (e) {
      print('Error loading bills: $e');
    }
  }

  // Load transactions with pagination
  Future<void> _loadTransactions({int page = 1}) async {
    try {
      // Calculate total pages
      final totalTransactionsSnapshot = await FBFireStore.transactions
          .where('customerId', isEqualTo: widget.customer.id)
          .get();
      final totalPages = (totalTransactionsSnapshot.size / _pageSize).ceil();

      Query query = FBFireStore.transactions
          .where('customerId', isEqualTo: widget.customer.id)
          .orderBy('timestamp', descending: true)
          .limit(_pageSize);

      if (page > 1 && _transactionsLastDoc != null) {
        query = query.startAfterDocument(_transactionsLastDoc!);
      }

      final snapshot = await query.get();
      final transactions = snapshot.docs
          .map(
            (doc) => TransactionModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      setState(() {
        _transactions = transactions;
        _transactionsCurrentPage = page;
        _transactionsTotalPages = totalPages > 0 ? totalPages : 1;
        _transactionsLastDoc = snapshot.docs.isNotEmpty
            ? snapshot.docs.last
            : null;
        _transactionsFirstDoc = snapshot.docs.isNotEmpty
            ? snapshot.docs.first
            : null;
      });
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.customer.name,
          style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar
                Container(
                  width: 280,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    border: Border(
                      right: BorderSide(color: AppColors.borderGrey),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Customer Summary Card
                      _buildCustomerCard(),
                      const Divider(height: 1),
                      // Menu Items
                      _buildSidebarMenuItem(
                        'Overview',
                        Icons.dashboard_outlined,
                        'overview',
                      ),
                      _buildSidebarMenuItem(
                        'Bills',
                        Icons.receipt_long_outlined,
                        'bills',
                      ),
                      _buildSidebarMenuItem(
                        'Transactions',
                        Icons.swap_horiz_outlined,
                        'transactions',
                      ),
                    ],
                  ),
                ),
                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: _buildSelectedView(),
                  ),
                ),
              ],
            ),
    );
  }

  // ===================== SIDEBAR CUSTOMER CARD =====================
  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              widget.customer.name.isNotEmpty
                  ? widget.customer.name[0].toUpperCase()
                  : 'C',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.customer.name,
            style: AppTextStyles.customContainerTitle.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            widget.customer.phone,
            style: AppTextStyles.tableRowSecondary,
            textAlign: TextAlign.center,
          ),
          if (widget.customer.email != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.customer.email!,
              style: AppTextStyles.tableRowSecondary,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          // Balance Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.customer.hasDebt
                  ? AppColors.errorSoft
                  : widget.customer.hasCredit
                  ? AppColors.successSoft
                  : AppColors.containerGreyColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.customer.hasDebt
                  ? 'Debt: \u20b9${widget.customer.balance.abs().toStringAsFixed(0)}'
                  : widget.customer.hasCredit
                  ? 'Credit: \u20b9${widget.customer.balance.toStringAsFixed(0)}'
                  : 'Balanced',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.customer.hasDebt
                    ? AppColors.error
                    : widget.customer.hasCredit
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== SIDEBAR MENU ITEM =====================
  Widget _buildSidebarMenuItem(String title, IconData icon, String viewId) {
    final isSelected = _selectedView == viewId;

    return InkWell(
      onTap: () => setState(() => _selectedView = viewId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== SELECTED VIEW =====================
  Widget _buildSelectedView() {
    switch (_selectedView) {
      case 'bills':
        return _buildBillsView();
      case 'transactions':
        return _buildTransactionsView();
      case 'overview':
      default:
        return _buildOverviewView();
    }
  }

  // ===================== OVERVIEW VIEW =====================
  Widget _buildOverviewView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Overview',
          style: AppTextStyles.headerHeading.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete customer information and performance metrics',
          style: AppTextStyles.headerSubheading,
        ),
        const SizedBox(height: 32),
        // Stats Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Sales',
                '\u20b9${widget.customer.totalPurchases.toStringAsFixed(0)}',
                Icons.shopping_cart_outlined,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Profit',
                '\u20b9${widget.customer.totalProfit.toStringAsFixed(0)}',
                Icons.trending_up_outlined,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Orders',
                '${widget.customer.orderCount}',
                Icons.receipt_long_outlined,
                AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Customer Details
        Text(
          'Customer Details',
          style: AppTextStyles.customContainerTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildCustomerInfo(),
        const SizedBox(height: 32),
        // Monthly Analytics
        Text(
          'Monthly Analytics',
          style: AppTextStyles.customContainerTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildMonthlyAnalyticsList(),
      ],
    );
  }

  // ===================== STAT CARD =====================
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.tableRowSecondary),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== CUSTOMER INFO =====================
  Widget _buildCustomerInfo() {
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
          _buildInfoRow('Phone', widget.customer.phone),
          if (widget.customer.email != null)
            _buildInfoRow('Email', widget.customer.email!),
          if (widget.customer.address != null)
            _buildInfoRow('Address', widget.customer.address!),
          _buildInfoRow(
            'Balance',
            '\u20b9${widget.customer.balance.toStringAsFixed(2)}',
          ),
          _buildInfoRow('Total Orders', '${widget.customer.orderCount}'),
          _buildInfoRow(
            'Total Sales',
            '\u20b9${widget.customer.totalPurchases.toStringAsFixed(2)}',
          ),
          _buildInfoRow(
            'Total Profit',
            '\u20b9${widget.customer.totalProfit.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== MONTHLY ANALYTICS LIST =====================
  Widget _buildMonthlyAnalyticsList() {
    if (_monthlyAnalytics.isEmpty) {
      return _buildEmptyState('No monthly analytics available');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _monthlyAnalytics.length > 6 ? 6 : _monthlyAnalytics.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final analytics = _monthlyAnalytics[index];
          return _buildMonthlyAnalyticsCard(analytics);
        },
      ),
    );
  }

  Widget _buildMonthlyAnalyticsCard(MonthlyCustomerAnalyticsModel analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analytics.id, // e.g., "2024-01"
                  style: AppTextStyles.tableRowPrimary.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${analytics.orderCount} orders',
                  style: AppTextStyles.tableRowSecondary,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u20b9${analytics.totalSales.toStringAsFixed(0)}',
                style: AppTextStyles.tableRowBoldValue.copyWith(
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Profit: \u20b9${analytics.totalProfit.toStringAsFixed(0)}',
                style: AppTextStyles.tableRowSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== BILLS VIEW =====================
  Widget _buildBillsView() {
    if (_bills.isEmpty) {
      return _buildEmptyState('No bills found');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Bills',
          style: AppTextStyles.headerHeading.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          'All bills associated with this customer',
          style: AppTextStyles.headerSubheading,
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bills.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildBillCard(_bills[index]);
            },
          ),
        ),
        if (_billsTotalPages > 1) ...[
          const SizedBox(height: 20),
          DynamicPagination(
            currentPage: _billsCurrentPage,
            totalPages: _billsTotalPages,
            onPageChanged: (page) {
              final isNextPage = page > _billsCurrentPage;
              _loadBills(page: page);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBillCard(BillModel bill) {
    final date = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(bill.createdAt.toDate());

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.receipt_long, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.billNo, style: AppTextStyles.tableRowPrimary),
                const SizedBox(height: 4),
                Text(date, style: AppTextStyles.tableRowSecondary),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u20b9${bill.finalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.tableRowBoldValue.copyWith(
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${bill.items.length} items',
                style: AppTextStyles.tableRowSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== TRANSACTIONS VIEW =====================
  Widget _buildTransactionsView() {
    if (_transactions.isEmpty) {
      return _buildEmptyState('No transactions found');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Transactions',
          style: AppTextStyles.headerHeading.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          'All payment transactions for this customer',
          style: AppTextStyles.headerSubheading,
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildTransactionCard(_transactions[index]);
            },
          ),
        ),
        if (_transactionsTotalPages > 1) ...[
          const SizedBox(height: 20),
          DynamicPagination(
            currentPage: _transactionsCurrentPage,
            totalPages: _transactionsTotalPages,
            onPageChanged: (page) {
              _loadTransactions(page: page);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final date = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(transaction.timestamp.toDate());

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.payment, color: AppColors.success, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.mode, style: AppTextStyles.tableRowPrimary),
                const SizedBox(height: 4),
                Text(date, style: AppTextStyles.tableRowSecondary),
              ],
            ),
          ),
          Text(
            '\u20b9${transaction.amount.toStringAsFixed(2)}',
            style: AppTextStyles.tableRowBoldValue.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== EMPTY STATE =====================
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.borderGrey),
            const SizedBox(height: 16),
            Text(message, style: AppTextStyles.tableRowPrimary),
          ],
        ),
      ),
    );
  }
}
