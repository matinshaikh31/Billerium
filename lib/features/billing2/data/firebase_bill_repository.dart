// ============================================
// 4. BILL REPOSITORY
// ============================================
// File: bill_repository.dart

import 'package:billing_software/features/billing2/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing2/domain/entity/payment_model.dart';

abstract class BillRepository {
  Future<String> createBill(BillModel bill);
  Future<void> updateBill(BillModel bill);
  Future<void> addPayment(String billId, PaymentModel payment);
  Future<List<BillModel>> searchBills(String query);
}

// ============================================
// 5. FIREBASE BILL REPOSITORY
// ============================================
// File: firebase_bill_repository.dart
