import '../models/bill_model.dart';
import '../models/payment_model.dart';

abstract class BillRepository {
  Future<List<BillModel>> getAllBills();
  Future<BillModel> getBillById(String id);
  Future<String> createBill(BillModel bill);
  Future<void> updateBill(BillModel bill);
  Future<void> addPayment(String billId, PaymentModel payment);
  Future<List<BillModel>> getBillsByStatus(String status);
  Future<List<BillModel>> getBillsByDateRange(DateTime start, DateTime end);
  Stream<List<BillModel>> watchBills();
}

