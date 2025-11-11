import 'package:billing_software/features/billing/domain/entity/bill_model.dart';

abstract class AnalyticsRepo {
  Future<void> updateAnalyticsOnBillCreate(BillModel bill);
  Future<void> updateAnalyticsOnPayment(double amount, bool isFullyPaid);
}
