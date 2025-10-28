import '../../features/billing/domain/models/bill_item_model.dart';
import '../constants/app_constants.dart';

class BillingCalculator {
  static Map<String, double> calculateBillTotals({
    required List<BillItemModel> items,
    double billDiscountPercent = 0,
    double billDiscountFlat = 0,
  }) {
    // Calculate item-level totals
    double subtotal = 0;
    double totalDiscount = 0;
    double totalTax = 0;

    for (var item in items) {
      subtotal += item.subtotal;
      totalDiscount += item.discountAmount;
      totalTax += item.taxAmount;
    }

    // Calculate after item discounts and taxes
    double afterItemCalculations = subtotal - totalDiscount + totalTax;

    // Apply bill-level discount
    double billDiscountAmount = 0;
    if (billDiscountPercent > 0) {
      billDiscountAmount = afterItemCalculations * (billDiscountPercent / 100);
    } else if (billDiscountFlat > 0) {
      billDiscountAmount = billDiscountFlat;
    }

    double finalAmount = afterItemCalculations - billDiscountAmount;

    return {
      'subtotal': subtotal,
      'totalDiscount': totalDiscount,
      'totalTax': totalTax,
      'billDiscountAmount': billDiscountAmount,
      'finalAmount': finalAmount > 0 ? finalAmount : 0,
    };
  }

  static String getBillStatus(double finalAmount, double amountPaid) {
    if (amountPaid >= finalAmount) {
      return AppConstants.billStatusPaid;
    } else if (amountPaid > 0) {
      return AppConstants.billStatusPartiallyPaid;
    } else {
      return AppConstants.billStatusUnpaid;
    }
  }

  static double getPendingAmount(double finalAmount, double amountPaid) {
    final pending = finalAmount - amountPaid;
    return pending > 0 ? pending : 0;
  }
}

