import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/billing_calculator.dart';
import '../../domain/models/bill_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/repositories/bill_repository.dart';
import '../dto/bill_dto.dart';

class FirebaseBillRepository implements BillRepository {
  final FirebaseFirestore _firestore;

  FirebaseBillRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _billsCollection =>
      _firestore.collection(AppConstants.billsCollection);

  @override
  Future<List<BillModel>> getAllBills() async {
    try {
      final snapshot = await _billsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => BillDto.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ).toModel(),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get bills: ${e.toString()}');
    }
  }

  @override
  Future<BillModel> getBillById(String id) async {
    try {
      final doc = await _billsCollection.doc(id).get();

      if (!doc.exists) {
        throw Exception('Bill not found');
      }

      return BillDto.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ).toModel();
    } catch (e) {
      throw Exception('Failed to get bill: ${e.toString()}');
    }
  }

  @override
  Future<String> createBill(BillModel bill) async {
    try {
      final now = Timestamp.now();
      final dto = BillDto.fromModel(bill);
      final data = dto.toJson();
      data['createdAt'] = now;
      data['updatedAt'] = now;

      final docRef = await _billsCollection.add(data);

      // Update stock for each item
      for (var item in bill.items) {
        await _updateProductStock(item.productId, -item.quantity);
        await _createStockHistory(
          item.productId,
          -item.quantity,
          AppConstants.stockReasonBilling,
        );
      }

      // Create transaction records
      for (var payment in bill.payments) {
        await _createTransaction(
          billId: docRef.id,
          customerName: bill.customerName ?? 'Walk-in Customer',
          amount: payment.amount,
          mode: payment.mode,
          timestamp: payment.timestamp,
        );
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create bill: ${e.toString()}');
    }
  }

  @override
  Future<void> updateBill(BillModel bill) async {
    try {
      final dto = BillDto.fromModel(bill);
      final data = dto.toJson();
      data['updatedAt'] = Timestamp.now();

      await _billsCollection.doc(bill.id).update(data);
    } catch (e) {
      throw Exception('Failed to update bill: ${e.toString()}');
    }
  }

  @override
  Future<void> addPayment(String billId, PaymentModel payment) async {
    try {
      final bill = await getBillById(billId);

      final updatedPayments = [...bill.payments, payment];
      final totalPaid = updatedPayments.fold<double>(
        0,
        (total, p) => total + p.amount,
      );

      final newStatus = BillingCalculator.getBillStatus(
        bill.finalAmount,
        totalPaid,
      );

      final pendingAmount = BillingCalculator.getPendingAmount(
        bill.finalAmount,
        totalPaid,
      );

      await _billsCollection.doc(billId).update({
        'payments': updatedPayments
            .map(
              (p) => {
                'id': p.id,
                'amount': p.amount,
                'mode': p.mode,
                'timestamp': Timestamp.fromDate(p.timestamp),
              },
            )
            .toList(),
        'amountPaid': totalPaid,
        'pendingAmount': pendingAmount,
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });

      // Create transaction record
      await _createTransaction(
        billId: billId,
        customerName: bill.customerName ?? 'Walk-in Customer',
        amount: payment.amount,
        mode: payment.mode,
        timestamp: payment.timestamp,
      );
    } catch (e) {
      throw Exception('Failed to add payment: ${e.toString()}');
    }
  }

  @override
  Future<List<BillModel>> getBillsByStatus(String status) async {
    try {
      final snapshot = await _billsCollection
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => BillDto.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ).toModel(),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get bills by status: ${e.toString()}');
    }
  }

  @override
  Future<List<BillModel>> getBillsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _billsCollection
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => BillDto.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ).toModel(),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get bills by date range: ${e.toString()}');
    }
  }

  @override
  Stream<List<BillModel>> watchBills() {
    return _billsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => BillDto.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ).toModel(),
              )
              .toList();
        });
  }

  Future<void> _updateProductStock(String productId, int quantity) async {
    final productDoc = await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .get();

    if (productDoc.exists) {
      final currentStock = productDoc.data()!['stockQty'] as int;
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({
            'stockQty': currentStock + quantity,
            'updatedAt': Timestamp.now(),
          });
    }
  }

  Future<void> _createStockHistory(
    String productId,
    int qtyChange,
    String reason,
  ) async {
    await _firestore.collection(AppConstants.stockHistoryCollection).add({
      'productId': productId,
      'qtyChange': qtyChange,
      'reason': reason,
      'date': Timestamp.now(),
    });
  }

  Future<void> _createTransaction({
    required String billId,
    required String customerName,
    required double amount,
    required String mode,
    required DateTime timestamp,
  }) async {
    await _firestore.collection(AppConstants.transactionsCollection).add({
      'billId': billId,
      'customerName': customerName,
      'amount': amount,
      'mode': mode,
      'timestamp': Timestamp.fromDate(timestamp),
    });
  }
}
