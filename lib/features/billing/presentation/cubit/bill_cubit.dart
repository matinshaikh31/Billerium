import 'dart:async';
import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/core/utils/helpers.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:billing_software/features/billing/domain/repo/fbill_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

part 'bill_state.dart';

class BillCubit extends Cubit<BillState> {
  final TextEditingController searchController = TextEditingController();
  final int _pageSize = 10;
  Timer? debounce;
  BillRepository billRepository;
  BillCubit({required this.billRepository}) : super(BillState.initial());

  @override
  Future<void> close() {
    debounce?.cancel();
    searchController.dispose();
    return super.close();
  }

  // Initialize bills pagination
  Future<void> initializeBillsPagination() async {
    searchController.clear();

    emit(
      state.copyWith(
        isLoading: true,
        filteredBills: [],
        lastFetchedDoc: null,
        firstFetchedDoc: null,
        searchedBills: [],
        currentPage: 1,
        totalPages: 1,
        error: null,
        searchQuery: '',
      ),
    );

    final totalPages = (await getTotalBillsCount() / _pageSize).ceil();

    try {
      Query query = _buildBaseQuery(null).limit(_pageSize);

      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        final bills = snap.docs
            .map(
              (doc) => BillModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final newLastFetchedDoc = snap.docs.last;
        final newFirstFetchedDoc = snap.docs.first;

        emit(
          state.copyWith(
            filteredBills: bills,
            lastFetchedDoc: newLastFetchedDoc,
            firstFetchedDoc: newFirstFetchedDoc,
            totalPages: totalPages,
            isLoading: false,
          ),
        );
      } else {
        emit(
          state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Build base query with filters
  Query _buildBaseQuery(bool? isNext) {
    Query query;

    if (isNext == null) {
      query = FBFireStore.bills.orderBy('createdAt', descending: true);
    } else if (isNext) {
      query = FBFireStore.bills.orderBy('createdAt', descending: true);
    } else {
      query = FBFireStore.bills.orderBy('createdAt', descending: false);
    }

    // Apply status filter
    if (state.statusFilter != null && state.statusFilter != 'All') {
      query = query.where('status', isEqualTo: state.statusFilter);
    }

    // Apply date range filter
    if (state.startDate != null && state.endDate != null) {
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: state.startDate)
          .where('createdAt', isLessThanOrEqualTo: state.endDate);
    }

    return query;
  }

  // Fetch next page
  Future<void> fetchNextBillsPage({required int page}) async {
    try {
      final isNextPage = page > state.currentPage;
      emit(state.copyWith(isLoading: true, currentPage: page));

      if (page == 1) {
        emit(state.copyWith(lastFetchedDoc: null, firstFetchedDoc: null));

        Query query = _buildBaseQuery(null).limit(_pageSize);

        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          final bills = snap.docs
              .map(
                (doc) => BillModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          final newLastFetchedDoc = snap.docs.last;
          final newFirstFetchedDoc = snap.docs.first;

          emit(
            state.copyWith(
              filteredBills: bills,
              lastFetchedDoc: newLastFetchedDoc,
              firstFetchedDoc: newFirstFetchedDoc,
              isLoading: false,
            ),
          );
        } else {
          emit(
            state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
          );
        }

        return;
      }

      if (isNextPage) {
        Query query = _buildBaseQuery(true).limit(_pageSize);

        if (state.lastFetchedDoc != null) {
          query = query.startAfterDocument(state.lastFetchedDoc!);
        }

        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          final bills = snap.docs
              .map(
                (doc) => BillModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          final newLastFetchedDoc = snap.docs.last;
          final newFirstFetchedDoc = snap.docs.first;

          emit(
            state.copyWith(
              filteredBills: bills,
              lastFetchedDoc: newLastFetchedDoc,
              firstFetchedDoc: newFirstFetchedDoc,
              isLoading: false,
            ),
          );
        } else {
          emit(
            state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
          );
        }
      } else {
        // Previous page - FIXED LOGIC
        Query query = _buildBaseQuery(false).limit(_pageSize);

        if (state.firstFetchedDoc != null) {
          query = query.startAfterDocument(state.firstFetchedDoc!);
        }

        final snap = await query.get();

        if (snap.docs.isNotEmpty) {
          final bills = snap.docs
              .map(
                (doc) => BillModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          // CRITICAL FIX: Reverse the cursor documents for previous page
          final newFirstFetchedDoc = snap.docs.last;
          final newLastFetchedDoc = snap.docs.first;

          // Sort bills in descending order (newest first)
          bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          emit(
            state.copyWith(
              filteredBills: bills,
              firstFetchedDoc: newFirstFetchedDoc,
              lastFetchedDoc: newLastFetchedDoc,
              isLoading: false,
            ),
          );
        } else {
          emit(
            state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Search bills
  void searchBills(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();

    emit(state.copyWith(searchQuery: query, isLoading: true));

    if (query.trim().isEmpty) {
      emit(
        state.copyWith(searchedBills: [], searchQuery: '', isLoading: false),
      );
      return;
    }

    debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(state.copyWith(isLoading: true));

        Query searchQuery;

        final hasActiveFilter =
            state.statusFilter != null && state.statusFilter != 'All' ||
            state.startDate != null;

        if (hasActiveFilter) {
          searchQuery = _buildBaseQuery(null);
        } else {
          searchQuery = FBFireStore.bills.orderBy(
            'createdAt',
            descending: true,
          );
        }

        final snapshot = await searchQuery.limit(50).get();

        final allBills = snapshot.docs
            .map(
              (doc) => BillModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final searchLower = query.toLowerCase();
        final results = allBills
            .where((bill) {
              return (bill.customerName?.toLowerCase().contains(searchLower) ??
                      false) ||
                  (bill.customerPhone?.toLowerCase().contains(searchLower) ??
                      false);
            })
            .take(50)
            .toList();

        emit(state.copyWith(searchedBills: results, isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: 'Search failed: $e'));
      }
    });
  }

  // Filter by status
  Future<void> filterByStatus(String? status) async {
    emit(state.copyWith(statusFilter: status, searchQuery: ''));
    searchController.clear();
    await initializeBillsPagination();
  }

  // Filter by date range
  Future<void> filterByDateRange(
    String? range, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    DateTime? start;
    DateTime? end;

    if (range == null) {
      // Clear filter
      start = null;
      end = null;
    } else if (range == 'LastWeek') {
      end = DateTime.now();
      start = end.subtract(const Duration(days: 7));
    } else if (range == 'LastMonth') {
      end = DateTime.now();
      start = DateTime(end.year, end.month - 1, end.day);
    } else if (range == 'Last3Months') {
      end = DateTime.now();
      start = DateTime(end.year, end.month - 3, end.day);
    } else if (range == 'Custom' && startDate != null && endDate != null) {
      start = startDate;
      end = endDate;
    }

    emit(
      state.copyWith(
        dateRangeFilter: range,
        startDate: start != null ? Timestamp.fromDate(start) : null,
        endDate: end != null ? Timestamp.fromDate(end) : null,
        searchQuery: '',
      ),
    );
    searchController.clear();
    await initializeBillsPagination();
  }

  Future<int> getTotalBillsCount() async {
    try {
      final query = _buildBaseQuery(null);
      final countSnapshot = await query.count().get();
      return countSnapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== SMART REFRESH METHODS ====================

  // Refresh current page
  Future<void> refreshCurrentPage() async {
    if (state.currentPage == 1) {
      await initializeBillsPagination();
    } else {
      await fetchNextBillsPage(page: state.currentPage);
    }
  }

  // Update bill in current list
  void updateBillInList(BillModel updatedBill) {
    final currentBills = List<BillModel>.from(state.filteredBills);
    final index = currentBills.indexWhere((b) => b.id == updatedBill.id);

    if (index != -1) {
      currentBills[index] = updatedBill;
      emit(state.copyWith(filteredBills: currentBills));
    }
  }

  // Remove bill from current list
  Future<void> removeBillFromList(String billId) async {
    final currentBills = List<BillModel>.from(state.filteredBills);
    currentBills.removeWhere((b) => b.id == billId);

    if (currentBills.isEmpty && state.currentPage > 1) {
      await fetchNextBillsPage(page: state.currentPage - 1);
    } else {
      emit(state.copyWith(filteredBills: currentBills));
      await refreshCurrentPage();
    }
  }

  Future<void> addPaymentToBill(
    String billId,
    double amount,
    String mode,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Create payment model
      final newPayment = PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        mode: mode,
        paidAt: Timestamp.now(),
      );

      // USE REPOSITORY METHOD
      await billRepository.addPayment(billId, newPayment);

      // Fetch updated bill for UI refresh
      final updatedBillDoc = await FBFireStore.bills.doc(billId).get();
      final updatedBillData = updatedBillDoc.data() as Map<String, dynamic>;
      final updatedBill = BillModel.fromJson(
        updatedBillData,
        updatedBillDoc.id,
      );

      // Smart refresh
      if (state.currentPage == 1) {
        await initializeBillsPagination();
      } else {
        updateBillInList(updatedBill);
      }

      emit(state.copyWith(isLoading: false, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Payment failed: $e'));
    }
  }

  // Refresh
  Future<void> refresh() async {
    await initializeBillsPagination();
  }

  // ==================== DELETE BILL ====================
  Future<bool> deleteBill(String billId) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Delete bill using repository (handles stock restoration and analytics reversal)
      await billRepository.deleteBill(billId);

      // Remove from current list and refresh
      await removeBillFromList(billId);

      emit(state.copyWith(isLoading: false, error: null));
      return true;
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: 'Failed to delete bill: $e'),
      );
      return false;
    }
  }

  // ==================== GET BILL BY ID ====================
  Future<BillModel?> getBillById(String billId) async {
    try {
      return await billRepository.getBillById(billId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to get bill: $e'));
      return null;
    }
  }

  // ==================== PDF GENERATION METHODS ====================

  // Generate and share invoice PDF
  Future<void> generateAndShareInvoice(BillModel bill) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Load images
      final logoImage = await _loadLogoImage();
      final signatureImage = await _loadSignatureImage();

      // Create PDF document
      final pdf = pw.Document();

      // Add page with invoice content - DYNAMIC HEIGHT
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [_buildInvoiceContent(bill, logoImage, signatureImage)];
          },
        ),
      );

      // Get temporary directory
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/invoice_${bill.billNo}.pdf');

      // Save PDF to file
      await file.writeAsBytes(await pdf.save());

      emit(state.copyWith(isLoading: false));

      // Share the PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice #${bill.billNo}',
        text: 'Invoice for ${bill.customerName ?? "Customer"}',
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: 'Failed to generate PDF: $e'),
      );
    }
  }

  // Print invoice directly
  Future<void> printInvoice(BillModel bill) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Load images
      final logoImage = await _loadLogoImage();
      final signatureImage = await _loadSignatureImage();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a3,
          build: (pw.Context context) {
            return [_buildInvoiceContent(bill, logoImage, signatureImage)];
          },
        ),
      );

      emit(state.copyWith(isLoading: false));

      // Open print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to print: $e'));
    }
  }

  // Build invoice PDF content - UPDATED WITH DYNAMIC SIZING
  pw.Widget _buildInvoiceContent(
    BillModel bill,
    pw.MemoryImage logoImage,
    pw.MemoryImage signatureImage,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final double subtotalBeforeDiscount = bill.items.fold(
      0.0,
      (sum, item) => sum + item.itemTotal + item.discountAmount,
    );

    final int totalQty = bill.items.fold(0, (sum, item) => sum + item.quantity);

    final double totalPriceBeforeDiscount = bill.items.fold(
      0.0,
      (sum, item) => sum + item.itemTotal + item.discountAmount,
    );

    final double totalDiscount = bill.items.fold(
      0.0,
      (sum, item) => sum + item.discountAmount,
    );

    final double finalTotal = bill.items.fold(
      0.0,
      (sum, item) => sum + item.itemTotal,
    );

    // 🔹 Derived column totals
    final double totalUnitPrice = bill.items.fold(
      0.0,
      (sum, item) =>
          sum +
          ((item.itemTotal + item.discountAmount) / item.quantity) *
              item.quantity,
    );

    final double totalUnitDiscount = bill.items.fold(
      0.0,
      (sum, item) => sum + item.discountAmount,
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header with Logo - COMPACT
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 50,
                    height: 50,
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'HA ENTERPRISES',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Alif Nagar Society, Tandalja Road',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                      pw.Text(
                        'Vadodara',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                      pw.Text(
                        'Phone: +91 9106554170',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Bill No: ${bill.billNo}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Date: ${dateFormat.format(bill.createdAt.toDate())}',
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 8),

        // Customer Details - COMPACT
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BILL TO',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                capitalizeWords(bill.customerName ?? "Walk-in Customer") ??
                    'Walk-in Customer',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (bill.customerPhone != null)
                pw.Text(
                  'Phone: ${bill.customerPhone}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
            ],
          ),
        ),

        pw.SizedBox(height: 8),

        // Items Table Header
        pw.Container(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey400),
              bottom: pw.BorderSide(color: PdfColors.grey400),
            ),
          ),
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'Item',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Center(
                  child: pw.Text(
                    'Category',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    'Price(1 pec.)',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    'Disc(1 pec.)',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    'Qty',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    'Total Price',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    'Total Disc',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    'Total',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Items List - COMPACT
        ...bill.items.map((item) {
          final originalUnitPrice =
              item.price + (item.discountAmount / item.quantity);
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    capitalizeWords(item.productName),
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    // color: PdfColors.red,
                    child: pw.Center(
                      child: pw.Text(
                        item.categoryName ?? '-',
                        style: pw.TextStyle(
                          fontSize: 7,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      'Rs.${item.price.toStringAsFixed(2)}',

                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      'Rs.${(item.discountAmount / item.quantity).toStringAsFixed(2)}',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      '${item.quantity}',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      'Rs.${(item.price * item.quantity).toStringAsFixed(2)}',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      'Rs.${item.discountAmount.toStringAsFixed(2)}',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      'Rs.${item.itemTotal.toStringAsFixed(2)}',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        pw.SizedBox(height: 8),
        pw.Container(
          decoration: pw.BoxDecoration(
            // color: PdfColors.blue700,
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.black, width: 1),
              bottom: pw.BorderSide(color: PdfColors.black, width: 1),
            ),
          ),
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
          child: pw.Row(
            children: [
              // Item column
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),

              // Category column
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  '',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.black),
                ),
              ),

              // Price (not needed for total)
              pw.Expanded(
                flex: 1,
                child: pw.Text('', textAlign: pw.TextAlign.right),
              ),

              // Disc (not needed for total)
              pw.Expanded(
                flex: 1,
                child: pw.Text('', textAlign: pw.TextAlign.right),
              ),

              // Qty TOTAL
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    totalQty.toString(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),

              // Total Price (BEFORE DISCOUNT)
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    'Rs.${totalPriceBeforeDiscount.toStringAsFixed(2)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),

              // Total Discount
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    'Rs.${totalDiscount.toStringAsFixed(2)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),

              // Final Total
              pw.Expanded(
                flex: 1,
                child: pw.Center(
                  child: pw.Text(
                    'Rs.${finalTotal.toStringAsFixed(2)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 8),

        // Totals Section - COMPACT
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Container(
              width: 180,
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  _buildTotalRow(
                    'Subtotal:',
                    'Rs.${subtotalBeforeDiscount.toStringAsFixed(2)}',
                  ),

                  if (bill.totalDiscount > 0)
                    _buildTotalRow(
                      'Discount:',
                      '-Rs.${bill.totalDiscount.toStringAsFixed(2)}',
                    ),
                  if (bill.totalTax > 0)
                    _buildTotalRow(
                      'Tax:',
                      'Rs.${bill.totalTax.toStringAsFixed(2)}',
                    ),
                  pw.Divider(thickness: 0.5),
                  _buildTotalRow(
                    'Grand Total:',
                    'Rs.${bill.finalAmount.toStringAsFixed(2)}',
                    isBold: true,
                    fontSize: 10,
                  ),
                  pw.SizedBox(height: 4),
                  _buildTotalRow(
                    'Amount Paid:',
                    'Rs.${bill.amountPaid.toStringAsFixed(2)}',
                    color: PdfColors.green700,
                  ),
                  if (bill.pendingAmount > 0)
                    _buildTotalRow(
                      'Pending:',
                      'Rs.${bill.pendingAmount.toStringAsFixed(2)}',
                      color: PdfColors.red700,
                      isBold: true,
                    ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 10),

        // Banking Details and Signature - UPDATED WITH REGISTRATION INFO
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Banking Details - NOW INCLUDES REGISTRATION INFO
            pw.Container(
              width: 260,
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'COMPANY DETAILS & BANKING',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  // Registration Details - NEWLY ADDED
                  _buildBankDetailRow('Registration No', '24BHBPS9737F1Z3'),
                  _buildBankDetailRow('Legal Name', 'SAEEDABANU SHAIKH'),
                  pw.Divider(height: 6, thickness: 0.5),
                  // Banking Details
                  _buildBankDetailRow('UDYAM No', 'UDYAM-GJ-24-0207943'),
                  _buildBankDetailRow('PAN', 'CIJPS4573E'),
                  _buildBankDetailRow('Bank Name', 'STATE BANK OF INDIA'),
                  _buildBankDetailRow('Branch', 'TANDALJA'),
                  _buildBankDetailRow('A/c No.', '20224295241'),
                  _buildBankDetailRow('IFSC Code', 'SBIN0010964'),
                ],
              ),
            ),
            // Signature
            pw.Container(
              width: 140,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'For H A Enterprises',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    'Authorised Signatory',
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 8),

        // Footer
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 3),
        pw.Center(
          child: pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
              fontSize: 8,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  pw.Widget _buildBankDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 85,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 7)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 8,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Load logo image from assets
  Future<pw.MemoryImage> _loadLogoImage() async {
    final ByteData bytes = await rootBundle.load('assets/bill_logo.png');
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  // Load signature image from assets
  Future<pw.MemoryImage> _loadSignatureImage() async {
    final ByteData bytes = await rootBundle.load('assets/bill_sig.jpg');
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }
}

// import 'dart:async';
// import 'package:billing_software/core/services/firebase.dart';
// import 'package:billing_software/core/utils/helpers.dart';
// import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
// import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
// import 'package:billing_software/features/billing/domain/repo/fbill_repository.dart';
// import 'package:bloc/bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:io';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';

// part 'bill_state.dart';

// class BillCubit extends Cubit<BillState> {
//   final TextEditingController searchController = TextEditingController();
//   final int _pageSize = 10;
//   Timer? debounce;
//   BillRepository billRepository;
//   BillCubit({required this.billRepository}) : super(BillState.initial());

//   @override
//   Future<void> close() {
//     debounce?.cancel();
//     searchController.dispose();
//     return super.close();
//   }

//   // Initialize bills pagination
//   Future<void> initializeBillsPagination() async {
//     searchController.clear();

//     emit(
//       state.copyWith(
//         isLoading: true,
//         filteredBills: [],
//         lastFetchedDoc: null,
//         firstFetchedDoc: null,
//         searchedBills: [],
//         currentPage: 1,
//         totalPages: 1,
//         error: null,
//         searchQuery: '',
//       ),
//     );

//     final totalPages = (await getTotalBillsCount() / _pageSize).ceil();

//     try {
//       Query query = _buildBaseQuery(null).limit(_pageSize);

//       final snap = await query.get();
//       if (snap.docs.isNotEmpty) {
//         final bills = snap.docs
//             .map(
//               (doc) => BillModel.fromDocSnap(
//                 doc as QueryDocumentSnapshot<Map<String, dynamic>>,
//               ),
//             )
//             .toList();

//         final newLastFetchedDoc = snap.docs.last;
//         final newFirstFetchedDoc = snap.docs.first;

//         emit(
//           state.copyWith(
//             filteredBills: bills,
//             lastFetchedDoc: newLastFetchedDoc,
//             firstFetchedDoc: newFirstFetchedDoc,
//             totalPages: totalPages,
//             isLoading: false,
//           ),
//         );
//       } else {
//         emit(
//           state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
//         );
//       }
//     } catch (e) {
//       emit(state.copyWith(isLoading: false, error: e.toString()));
//     }
//   }

//   // Build base query with filters
//   Query _buildBaseQuery(bool? isNext) {
//     Query query;

//     if (isNext == null) {
//       query = FBFireStore.bills.orderBy('createdAt', descending: true);
//     } else if (isNext) {
//       query = FBFireStore.bills.orderBy('createdAt', descending: true);
//     } else {
//       query = FBFireStore.bills.orderBy('createdAt', descending: false);
//     }

//     // Apply status filter
//     if (state.statusFilter != null && state.statusFilter != 'All') {
//       query = query.where('status', isEqualTo: state.statusFilter);
//     }

//     // Apply date range filter
//     if (state.startDate != null && state.endDate != null) {
//       query = query
//           .where('createdAt', isGreaterThanOrEqualTo: state.startDate)
//           .where('createdAt', isLessThanOrEqualTo: state.endDate);
//     }

//     return query;
//   }

//   // Fetch next page
//   Future<void> fetchNextBillsPage({required int page}) async {
//     try {
//       final isNextPage = page > state.currentPage;
//       emit(state.copyWith(isLoading: true, currentPage: page));

//       if (page == 1) {
//         emit(state.copyWith(lastFetchedDoc: null, firstFetchedDoc: null));

//         Query query = _buildBaseQuery(null).limit(_pageSize);

//         final snap = await query.get();
//         if (snap.docs.isNotEmpty) {
//           final bills = snap.docs
//               .map(
//                 (doc) => BillModel.fromDocSnap(
//                   doc as QueryDocumentSnapshot<Map<String, dynamic>>,
//                 ),
//               )
//               .toList();

//           final newLastFetchedDoc = snap.docs.last;
//           final newFirstFetchedDoc = snap.docs.first;

//           emit(
//             state.copyWith(
//               filteredBills: bills,
//               lastFetchedDoc: newLastFetchedDoc,
//               firstFetchedDoc: newFirstFetchedDoc,
//               isLoading: false,
//             ),
//           );
//         } else {
//           emit(
//             state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
//           );
//         }

//         return;
//       }

//       if (isNextPage) {
//         Query query = _buildBaseQuery(true).limit(_pageSize);

//         if (state.lastFetchedDoc != null) {
//           query = query.startAfterDocument(state.lastFetchedDoc!);
//         }

//         final snap = await query.get();
//         if (snap.docs.isNotEmpty) {
//           final bills = snap.docs
//               .map(
//                 (doc) => BillModel.fromDocSnap(
//                   doc as QueryDocumentSnapshot<Map<String, dynamic>>,
//                 ),
//               )
//               .toList();

//           final newLastFetchedDoc = snap.docs.last;
//           final newFirstFetchedDoc = snap.docs.first;

//           emit(
//             state.copyWith(
//               filteredBills: bills,
//               lastFetchedDoc: newLastFetchedDoc,
//               firstFetchedDoc: newFirstFetchedDoc,
//               isLoading: false,
//             ),
//           );
//         } else {
//           emit(
//             state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
//           );
//         }
//       } else {
//         // Previous page - FIXED LOGIC
//         Query query = _buildBaseQuery(false).limit(_pageSize);

//         if (state.firstFetchedDoc != null) {
//           query = query.startAfterDocument(state.firstFetchedDoc!);
//         }

//         final snap = await query.get();

//         if (snap.docs.isNotEmpty) {
//           final bills = snap.docs
//               .map(
//                 (doc) => BillModel.fromDocSnap(
//                   doc as QueryDocumentSnapshot<Map<String, dynamic>>,
//                 ),
//               )
//               .toList();

//           // CRITICAL FIX: Reverse the cursor documents for previous page
//           final newFirstFetchedDoc = snap.docs.last;
//           final newLastFetchedDoc = snap.docs.first;

//           // Sort bills in descending order (newest first)
//           bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//           emit(
//             state.copyWith(
//               filteredBills: bills,
//               firstFetchedDoc: newFirstFetchedDoc,
//               lastFetchedDoc: newLastFetchedDoc,
//               isLoading: false,
//             ),
//           );
//         } else {
//           emit(
//             state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//       emit(state.copyWith(isLoading: false, error: e.toString()));
//     }
//   }

//   // Search bills
//   void searchBills(String query) {
//     if (debounce?.isActive ?? false) debounce?.cancel();

//     emit(state.copyWith(searchQuery: query, isLoading: true));

//     if (query.trim().isEmpty) {
//       emit(
//         state.copyWith(searchedBills: [], searchQuery: '', isLoading: false),
//       );
//       return;
//     }

//     debounce = Timer(const Duration(milliseconds: 500), () async {
//       try {
//         emit(state.copyWith(isLoading: true));

//         Query searchQuery;

//         final hasActiveFilter =
//             state.statusFilter != null && state.statusFilter != 'All' ||
//             state.startDate != null;

//         if (hasActiveFilter) {
//           searchQuery = _buildBaseQuery(null);
//         } else {
//           searchQuery = FBFireStore.bills.orderBy(
//             'createdAt',
//             descending: true,
//           );
//         }

//         final snapshot = await searchQuery.limit(50).get();

//         final allBills = snapshot.docs
//             .map(
//               (doc) => BillModel.fromDocSnap(
//                 doc as QueryDocumentSnapshot<Map<String, dynamic>>,
//               ),
//             )
//             .toList();

//         final searchLower = query.toLowerCase();
//         final results = allBills
//             .where((bill) {
//               return (bill.customerName?.toLowerCase().contains(searchLower) ??
//                       false) ||
//                   (bill.customerPhone?.toLowerCase().contains(searchLower) ??
//                       false);
//             })
//             .take(50)
//             .toList();

//         emit(state.copyWith(searchedBills: results, isLoading: false));
//       } catch (e) {
//         emit(state.copyWith(isLoading: false, error: 'Search failed: $e'));
//       }
//     });
//   }

//   // Filter by status
//   Future<void> filterByStatus(String? status) async {
//     emit(state.copyWith(statusFilter: status, searchQuery: ''));
//     searchController.clear();
//     await initializeBillsPagination();
//   }

//   // Filter by date range
//   Future<void> filterByDateRange(
//     String? range, {
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     DateTime? start;
//     DateTime? end;

//     if (range == null) {
//       // Clear filter
//       start = null;
//       end = null;
//     } else if (range == 'LastWeek') {
//       end = DateTime.now();
//       start = end.subtract(const Duration(days: 7));
//     } else if (range == 'LastMonth') {
//       end = DateTime.now();
//       start = DateTime(end.year, end.month - 1, end.day);
//     } else if (range == 'Last3Months') {
//       end = DateTime.now();
//       start = DateTime(end.year, end.month - 3, end.day);
//     } else if (range == 'Custom' && startDate != null && endDate != null) {
//       start = startDate;
//       end = endDate;
//     }

//     emit(
//       state.copyWith(
//         dateRangeFilter: range,
//         startDate: start != null ? Timestamp.fromDate(start) : null,
//         endDate: end != null ? Timestamp.fromDate(end) : null,
//         searchQuery: '',
//       ),
//     );
//     searchController.clear();
//     await initializeBillsPagination();
//   }

//   Future<int> getTotalBillsCount() async {
//     try {
//       final query = _buildBaseQuery(null);
//       final countSnapshot = await query.count().get();
//       return countSnapshot.count ?? 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   // ==================== SMART REFRESH METHODS ====================

//   // Refresh current page
//   Future<void> refreshCurrentPage() async {
//     if (state.currentPage == 1) {
//       await initializeBillsPagination();
//     } else {
//       await fetchNextBillsPage(page: state.currentPage);
//     }
//   }

//   // Update bill in current list
//   void updateBillInList(BillModel updatedBill) {
//     final currentBills = List<BillModel>.from(state.filteredBills);
//     final index = currentBills.indexWhere((b) => b.id == updatedBill.id);

//     if (index != -1) {
//       currentBills[index] = updatedBill;
//       emit(state.copyWith(filteredBills: currentBills));
//     }
//   }

//   // Remove bill from current list
//   Future<void> removeBillFromList(String billId) async {
//     final currentBills = List<BillModel>.from(state.filteredBills);
//     currentBills.removeWhere((b) => b.id == billId);

//     if (currentBills.isEmpty && state.currentPage > 1) {
//       await fetchNextBillsPage(page: state.currentPage - 1);
//     } else {
//       emit(state.copyWith(filteredBills: currentBills));
//       await refreshCurrentPage();
//     }
//   }

//   Future<void> addPaymentToBill(
//     String billId,
//     double amount,
//     String mode,
//   ) async {
//     try {
//       emit(state.copyWith(isLoading: true));

//       // Create payment model
//       final newPayment = PaymentModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         amount: amount,
//         mode: mode,
//         paidAt: Timestamp.now(),
//       );

//       // USE REPOSITORY METHOD
//       await billRepository.addPayment(billId, newPayment);

//       // Fetch updated bill for UI refresh
//       final updatedBillDoc = await FBFireStore.bills.doc(billId).get();
//       final updatedBillData = updatedBillDoc.data() as Map<String, dynamic>;
//       final updatedBill = BillModel.fromJson(
//         updatedBillData,
//         updatedBillDoc.id,
//       );

//       // Smart refresh
//       if (state.currentPage == 1) {
//         await initializeBillsPagination();
//       } else {
//         updateBillInList(updatedBill);
//       }

//       emit(state.copyWith(isLoading: false, error: null));
//     } catch (e) {
//       emit(state.copyWith(isLoading: false, error: 'Payment failed: $e'));
//     }
//   }

//   // Refresh
//   Future<void> refresh() async {
//     await initializeBillsPagination();
//   }

//   // ==================== DELETE BILL ====================
//   Future<bool> deleteBill(String billId) async {
//     try {
//       emit(state.copyWith(isLoading: true));

//       // Delete bill using repository (handles stock restoration and analytics reversal)
//       await billRepository.deleteBill(billId);

//       // Remove from current list and refresh
//       await removeBillFromList(billId);

//       emit(state.copyWith(isLoading: false, error: null));
//       return true;
//     } catch (e) {
//       emit(
//         state.copyWith(isLoading: false, error: 'Failed to delete bill: $e'),
//       );
//       return false;
//     }
//   }

//   // ==================== GET BILL BY ID ====================
//   Future<BillModel?> getBillById(String billId) async {
//     try {
//       return await billRepository.getBillById(billId);
//     } catch (e) {
//       emit(state.copyWith(error: 'Failed to get bill: $e'));
//       return null;
//     }
//   }

//   // ==================== PDF GENERATION METHODS ====================

//   // Generate and share invoice PDF
//   Future<void> generateAndShareInvoice(BillModel bill) async {
//     try {
//       emit(state.copyWith(isLoading: true));

//       // Load images
//       final logoImage = await _loadLogoImage();
//       final signatureImage = await _loadSignatureImage();

//       // Create PDF document
//       final pdf = pw.Document();

//       // Add page with invoice content
//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           build: (pw.Context context) {
//             return _buildInvoiceContent(bill, logoImage, signatureImage);
//           },
//         ),
//       );

//       // Get temporary directory
//       final output = await getTemporaryDirectory();
//       final file = File('${output.path}/invoice_${bill.billNo}.pdf');

//       // Save PDF to file
//       await file.writeAsBytes(await pdf.save());

//       emit(state.copyWith(isLoading: false));

//       // Share the PDF
//       await Share.shareXFiles(
//         [XFile(file.path)],
//         subject: 'Invoice #${bill.billNo}',
//         text: 'Invoice for ${bill.customerName ?? "Customer"}',
//       );
//     } catch (e) {
//       emit(
//         state.copyWith(isLoading: false, error: 'Failed to generate PDF: $e'),
//       );
//     }
//   }

//   // Print invoice directly
//   Future<void> printInvoice(BillModel bill) async {
//     try {
//       emit(state.copyWith(isLoading: true));

//       // Load images
//       final logoImage = await _loadLogoImage();
//       final signatureImage = await _loadSignatureImage();

//       final pdf = pw.Document();

//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           build: (pw.Context context) {
//             return _buildInvoiceContent(bill, logoImage, signatureImage);
//           },
//         ),
//       );

//       emit(state.copyWith(isLoading: false));

//       // Open print dialog
//       await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save(),
//       );
//     } catch (e) {
//       emit(state.copyWith(isLoading: false, error: 'Failed to print: $e'));
//     }
//   }

//   // Build invoice PDF content
//   pw.Widget _buildInvoiceContent(
//     BillModel bill,
//     pw.MemoryImage logoImage,
//     pw.MemoryImage signatureImage,
//   ) {
//     final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(15),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           // Header with Logo - COMPACT
//           pw.Container(
//             padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: pw.BoxDecoration(
//               color: PdfColors.blue50,
//               borderRadius: pw.BorderRadius.circular(6),
//             ),
//             child: pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Row(
//                   children: [
//                     pw.Container(
//                       width: 50,
//                       height: 50,
//                       child: pw.Image(logoImage, fit: pw.BoxFit.contain),
//                     ),
//                     pw.SizedBox(width: 8),
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           'HA ENTERPRISES',
//                           style: pw.TextStyle(
//                             fontSize: 12,
//                             fontWeight: pw.FontWeight.bold,
//                             color: PdfColors.blue900,
//                           ),
//                         ),
//                         pw.SizedBox(height: 2),
//                         pw.Text(
//                           'Alif Nagar Society, Tandalja Road',
//                           style: const pw.TextStyle(fontSize: 7),
//                         ),
//                         pw.Text(
//                           'Vadodara',
//                           style: const pw.TextStyle(fontSize: 7),
//                         ),
//                         pw.Text(
//                           'Phone: +91 9106554170',
//                           style: const pw.TextStyle(fontSize: 7),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.end,
//                   children: [
//                     pw.Text(
//                       'INVOICE',
//                       style: pw.TextStyle(
//                         fontSize: 16,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                     pw.SizedBox(height: 4),
//                     pw.Text(
//                       'Bill No: ${bill.billNo}',
//                       style: pw.TextStyle(
//                         fontSize: 9,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                     pw.Text(
//                       'Date: ${dateFormat.format(bill.createdAt.toDate())}',
//                       style: const pw.TextStyle(fontSize: 7),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           pw.SizedBox(height: 8),

//           // Customer Details - COMPACT
//           pw.Container(
//             padding: const pw.EdgeInsets.all(6),
//             decoration: pw.BoxDecoration(
//               border: pw.Border.all(color: PdfColors.grey300),
//               borderRadius: pw.BorderRadius.circular(4),
//             ),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   'BILL TO',
//                   style: pw.TextStyle(
//                     fontSize: 8,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.grey700,
//                   ),
//                 ),
//                 pw.SizedBox(height: 2),
//                 pw.Text(
//                   capitalizeWords(bill.customerName ?? "Walk-in Customer") ??
//                       'Walk-in Customer',
//                   style: pw.TextStyle(
//                     fontSize: 10,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 if (bill.customerPhone != null)
//                   pw.Text(
//                     'Phone: ${bill.customerPhone}',
//                     style: const pw.TextStyle(fontSize: 8),
//                   ),
//               ],
//             ),
//           ),

//           pw.SizedBox(height: 8),

//           // Items Table Header
//           pw.Container(
//             decoration: const pw.BoxDecoration(
//               color: PdfColors.grey200,
//               border: pw.Border(
//                 top: pw.BorderSide(color: PdfColors.grey400),
//                 bottom: pw.BorderSide(color: PdfColors.grey400),
//               ),
//             ),
//             padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
//             child: pw.Row(
//               children: [
//                 pw.Expanded(
//                   flex: 2,
//                   child: pw.Text(
//                     'Item',
//                     style: pw.TextStyle(
//                       fontSize: 8,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.Expanded(
//                   flex: 2,
//                   child: pw.Text(
//                     'Category',
//                     style: pw.TextStyle(
//                       fontSize: 8,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.Expanded(
//                   flex: 1,
//                   child: pw.Text(
//                     'Price',
//                     textAlign: pw.TextAlign.right,
//                     style: pw.TextStyle(
//                       fontSize: 8,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.Expanded(
//                   flex: 1,
//                   child: pw.Text(
//                     'Qty',
//                     textAlign: pw.TextAlign.center,
//                     style: pw.TextStyle(
//                       fontSize: 8,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.Expanded(
//                   flex: 1,
//                   child: pw.Text(
//                     'Disc.',
//                     textAlign: pw.TextAlign.right,
//                     style: pw.TextStyle(
//                       fontSize: 8,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.Expanded(
//                   flex: 1,
//                   child: pw.Text(
//                     'Total',
//                     textAlign: pw.TextAlign.right,
//                     style: pw.TextStyle(
//                       fontSize: 8,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Items List - COMPACT
//           ...bill.items.map((item) {
//             return pw.Container(
//               decoration: pw.BoxDecoration(
//                 border: pw.Border(
//                   bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
//                 ),
//               ),
//               padding: const pw.EdgeInsets.symmetric(
//                 vertical: 3,
//                 horizontal: 6,
//               ),
//               child: pw.Row(
//                 children: [
//                   pw.Expanded(
//                     flex: 2,
//                     child: pw.Text(
//                       capitalizeWords(item.productName),
//                       style: const pw.TextStyle(fontSize: 7),
//                     ),
//                   ),
//                   pw.Expanded(
//                     flex: 2,
//                     child: pw.Text(
//                       item.categoryName ?? '-',
//                       style: pw.TextStyle(
//                         fontSize: 7,
//                         color: PdfColors.grey700,
//                       ),
//                     ),
//                   ),
//                   pw.Expanded(
//                     flex: 1,
//                     child: pw.Text(
//                       'Rs${item.price.toStringAsFixed(2)}',
//                       textAlign: pw.TextAlign.right,
//                       style: const pw.TextStyle(fontSize: 7),
//                     ),
//                   ),
//                   pw.Expanded(
//                     flex: 1,
//                     child: pw.Text(
//                       '${item.quantity}',
//                       textAlign: pw.TextAlign.center,
//                       style: const pw.TextStyle(fontSize: 7),
//                     ),
//                   ),
//                   pw.Expanded(
//                     flex: 1,
//                     child: pw.Text(
//                       'Rs${item.discountAmount.toStringAsFixed(2)}',
//                       textAlign: pw.TextAlign.right,
//                       style: const pw.TextStyle(fontSize: 7),
//                     ),
//                   ),
//                   pw.Expanded(
//                     flex: 1,
//                     child: pw.Text(
//                       'Rs${item.itemTotal.toStringAsFixed(2)}',
//                       textAlign: pw.TextAlign.right,
//                       style: const pw.TextStyle(fontSize: 7),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),

//           pw.SizedBox(height: 8),

//           // Totals Section - COMPACT
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.end,
//             children: [
//               pw.Container(
//                 width: 180,
//                 padding: const pw.EdgeInsets.all(6),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey300),
//                   borderRadius: pw.BorderRadius.circular(4),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     _buildTotalRow(
//                       'Subtotal:',
//                       'Rs${bill.subtotal.toStringAsFixed(2)}',
//                     ),
//                     if (bill.totalDiscount > 0)
//                       _buildTotalRow(
//                         'Discount:',
//                         '-Rs${bill.totalDiscount.toStringAsFixed(2)}',
//                       ),
//                     if (bill.totalTax > 0)
//                       _buildTotalRow(
//                         'Tax:',
//                         'Rs${bill.totalTax.toStringAsFixed(2)}',
//                       ),
//                     pw.Divider(thickness: 0.5),
//                     _buildTotalRow(
//                       'Grand Total:',
//                       'Rs${bill.finalAmount.toStringAsFixed(2)}',
//                       isBold: true,
//                       fontSize: 10,
//                     ),
//                     pw.SizedBox(height: 4),
//                     _buildTotalRow(
//                       'Amount Paid:',
//                       'Rs${bill.amountPaid.toStringAsFixed(2)}',
//                       color: PdfColors.green700,
//                     ),
//                     if (bill.pendingAmount > 0)
//                       _buildTotalRow(
//                         'Pending:',
//                         'Rs${bill.pendingAmount.toStringAsFixed(2)}',
//                         color: PdfColors.red700,
//                         isBold: true,
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           pw.SizedBox(height: 10),

//           // Banking Details and Signature - COMPACT
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Banking Details
//               pw.Container(
//                 width: 240,
//                 padding: const pw.EdgeInsets.all(6),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey300),
//                   borderRadius: pw.BorderRadius.circular(4),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'BANKING DETAILS',
//                       style: pw.TextStyle(
//                         fontSize: 8,
//                         fontWeight: pw.FontWeight.bold,
//                         color: PdfColors.grey700,
//                       ),
//                     ),
//                     pw.SizedBox(height: 3),
//                     _buildBankDetailRow('UDYAM No', 'UDYAM-GJ-24-0207943'),
//                     _buildBankDetailRow('PAN', 'CIJPS4573E'),
//                     _buildBankDetailRow('Bank Name', 'STATE BANK OF INDIA'),
//                     _buildBankDetailRow('Branch', 'TANDALJA'),
//                     _buildBankDetailRow('A/c No.', '20224295241'),
//                     _buildBankDetailRow('IFSC Code', 'SBIN0010964'),
//                   ],
//                 ),
//               ),
//               // Signature
//               pw.Container(
//                 width: 140,
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.center,
//                   children: [
//                     pw.Text(
//                       'For H A Enterprises',
//                       style: pw.TextStyle(
//                         fontSize: 8,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                     pw.SizedBox(height: 15),
//                     pw.Text(
//                       'Authorised Signatory',
//                       style: pw.TextStyle(
//                         fontSize: 7,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           pw.SizedBox(height: 8),

//           // Footer
//           pw.Divider(thickness: 0.5),
//           pw.SizedBox(height: 3),
//           pw.Center(
//             child: pw.Text(
//               'Thank you for your business!',
//               style: pw.TextStyle(
//                 fontSize: 8,
//                 fontStyle: pw.FontStyle.italic,
//                 color: PdfColors.grey600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper methods
//   pw.Widget _buildBankDetailRow(String label, String value) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Container(
//             width: 65,
//             child: pw.Text(
//               '$label:',
//               style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
//             ),
//           ),
//           pw.Expanded(
//             child: pw.Text(value, style: const pw.TextStyle(fontSize: 7)),
//           ),
//         ],
//       ),
//     );
//   }

//   pw.Widget _buildTotalRow(
//     String label,
//     String value, {
//     bool isBold = false,
//     double fontSize = 8,
//     PdfColor? color,
//   }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(
//             label,
//             style: pw.TextStyle(
//               fontSize: fontSize,
//               fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//               color: color,
//             ),
//           ),
//           pw.Text(
//             value,
//             style: pw.TextStyle(
//               fontSize: fontSize,
//               fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== HELPER METHODS ====================

//   // Build bank detail rows
//   // pw.Widget _buildBankDetailRow(String label, String value) {
//   //   return pw.Padding(
//   //     padding: const pw.EdgeInsets.symmetric(vertical: 3),
//   //     child: pw.Row(
//   //       crossAxisAlignment: pw.CrossAxisAlignment.start,
//   //       children: [
//   //         pw.Container(
//   //           width: 80,
//   //           child: pw.Text(
//   //             '$label:',
//   //             style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//   //           ),
//   //         ),
//   //         pw.Expanded(
//   //           child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Build table cells
//   pw.Widget _buildTableCell(
//     String text, {
//     bool isHeader = false,
//     pw.TextAlign align = pw.TextAlign.left,
//   }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: isHeader ? 11 : 10,
//           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//         ),
//         textAlign: align,
//       ),
//     );
//   }

//   // Build total rows
//   // pw.Widget _buildTotalRow(
//   //   String label,
//   //   String value, {
//   //   bool isBold = false,
//   //   double fontSize = 12,
//   //   PdfColor? color,
//   // }) {
//   //   return pw.Padding(
//   //     padding: const pw.EdgeInsets.symmetric(vertical: 5),
//   //     child: pw.Row(
//   //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//   //       children: [
//   //         pw.Text(
//   //           label,
//   //           style: pw.TextStyle(
//   //             fontSize: fontSize,
//   //             fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//   //             color: color,
//   //           ),
//   //         ),
//   //         pw.Text(
//   //           value,
//   //           style: pw.TextStyle(
//   //             fontSize: fontSize,
//   //             fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
//   //             color: color,
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Load logo image from assets
//   Future<pw.MemoryImage> _loadLogoImage() async {
//     final ByteData bytes = await rootBundle.load('assets/bill_logo.png');
//     return pw.MemoryImage(bytes.buffer.asUint8List());
//   }

//   // Load signature image from assets
//   Future<pw.MemoryImage> _loadSignatureImage() async {
//     final ByteData bytes = await rootBundle.load('assets/bill_sig.jpg');
//     return pw.MemoryImage(bytes.buffer.asUint8List());
//   }
// }
