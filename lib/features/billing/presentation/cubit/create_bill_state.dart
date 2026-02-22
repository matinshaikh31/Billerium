part of 'create_bill_cubit.dart';

class CreateBillState {
  final List<BillItemModel> cartItems;
  final String? customerGstNumber;
  final double amountReceived;
  final String paymentMode;
  final bool isLoading;
  final String? message;

  // Bill-level discount fields
  final double billDiscountPercent;
  final double billDiscountAmount;

  // Tax rates from settings
  final int cgstRate;
  final int sgstRate;

  // Bill date (for creating bills for past/future dates)
  final DateTime billDate;

  CreateBillState({
    required this.cartItems,
    this.customerGstNumber,
    required this.amountReceived,
    required this.paymentMode,
    required this.isLoading,
    this.message,
    this.billDiscountPercent = 0,
    this.billDiscountAmount = 0,
    this.cgstRate = 9,
    this.sgstRate = 9,
    required this.billDate,
  });

  factory CreateBillState.initial() {
    return CreateBillState(
      cartItems: [],
      amountReceived: 0,
      paymentMode: 'Cash',
      isLoading: false,
      message: null,
      billDiscountPercent: 0,
      billDiscountAmount: 0,
      billDate: DateTime.now(),
    );
  }

  // Calculate total before ALL discounts (product + bill) and before tax
  // This is just price * quantity for all items
  double get totalBeforeDiscount {
    return cartItems.fold(
      0.0,
      (total, item) => total + (item.price * item.quantity),
    );
  }

  // Calculate subtotal (sum of all item totals AFTER their individual discounts)
  double get subtotal {
    return cartItems.fold(0.0, (total, item) => total + item.itemTotal);
  }

  // Calculate total discount from items (product-level discounts)
  double get totalDiscount {
    return cartItems.fold(0.0, (total, item) => total + item.discountAmount);
  }

  // Calculate bill discount amount based on percent or fixed value
  double get calculatedBillDiscount {
    if (billDiscountPercent > 0) {
      return subtotal * billDiscountPercent / 100;
    }
    return billDiscountAmount;
  }

  // Calculate CGST (applied on amount after all discounts)
  double get cgst {
    final amountAfterAllDiscounts =
        totalBeforeDiscount - totalDiscount - calculatedBillDiscount;
    return amountAfterAllDiscounts * (cgstRate / 100);
  }

  // Calculate SGST (applied on amount after all discounts)
  double get sgst {
    final amountAfterAllDiscounts =
        totalBeforeDiscount - totalDiscount - calculatedBillDiscount;
    return amountAfterAllDiscounts * (sgstRate / 100);
  }

  // Calculate total tax (CGST + SGST)
  double get totalTax {
    return cgst + sgst;
  }

  // Grand total = totalBeforeDiscount - totalDiscount - billDiscount + tax
  double get grandTotal {
    final total =
        totalBeforeDiscount - totalDiscount - calculatedBillDiscount + totalTax;
    return total < 0 ? 0 : total;
  }

  // Calculate pending amount
  double get pendingAmount {
    final pending = grandTotal - amountReceived;
    return pending < 0 ? 0 : pending;
  }

  CreateBillState copyWith({
    List<BillItemModel>? cartItems,
    String? customerGstNumber,
    double? amountReceived,
    String? paymentMode,
    bool? isLoading,
    String? message,
    double? billDiscountPercent,
    double? billDiscountAmount,
    int? cgstRate,
    int? sgstRate,
    DateTime? billDate,
  }) {
    return CreateBillState(
      cartItems: cartItems ?? this.cartItems,
      customerGstNumber: customerGstNumber ?? this.customerGstNumber,
      amountReceived: amountReceived ?? this.amountReceived,
      paymentMode: paymentMode ?? this.paymentMode,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      billDiscountPercent: billDiscountPercent ?? this.billDiscountPercent,
      billDiscountAmount: billDiscountAmount ?? this.billDiscountAmount,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      billDate: billDate ?? this.billDate,
    );
  }
}
