part of 'edit_bill_cubit.dart';

class EditBillState {
  final BillModel? originalBill;
  final List<BillItemModel> cartItems;
  final String? customerName;
  final String? customerPhone;
  final double amountReceived;
  final String paymentMode;
  final bool isLoading;
  final String? message;
  final bool isSuccess;

  // Bill-level discount fields
  final double billDiscountPercent;
  final double billDiscountAmount;

  // Bill date
  final DateTime billDate;

  EditBillState({
    this.originalBill,
    required this.cartItems,
    this.customerName,
    this.customerPhone,
    required this.amountReceived,
    required this.paymentMode,
    required this.isLoading,
    this.message,
    this.isSuccess = false,
    this.billDiscountPercent = 0,
    this.billDiscountAmount = 0,
    required this.billDate,
  });

  factory EditBillState.initial() {
    return EditBillState(
      originalBill: null,
      cartItems: [],
      customerName: null,
      customerPhone: null,
      amountReceived: 0,
      paymentMode: 'Cash',
      isLoading: false,
      message: null,
      isSuccess: false,
      billDiscountPercent: 0,
      billDiscountAmount: 0,
      billDate: DateTime.now(),
    );
  }

  // Calculate subtotal (sum of all item totals AFTER their individual discounts)
  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  // Calculate total discount from items (product-level discounts)
  double get totalDiscount {
    return cartItems.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  // Calculate bill discount amount based on percent or fixed value
  double get calculatedBillDiscount {
    if (billDiscountPercent > 0) {
      return subtotal * billDiscountPercent / 100;
    }
    return billDiscountAmount;
  }

  // Grand total = subtotal - bill discount
  double get grandTotal {
    final total = subtotal - calculatedBillDiscount;
    return total < 0 ? 0 : total;
  }

  // Calculate pending amount
  double get pendingAmount {
    final pending = grandTotal - amountReceived;
    return pending < 0 ? 0 : pending;
  }

  EditBillState copyWith({
    BillModel? originalBill,
    List<BillItemModel>? cartItems,
    String? customerName,
    String? customerPhone,
    double? amountReceived,
    String? paymentMode,
    bool? isLoading,
    String? message,
    bool? isSuccess,
    double? billDiscountPercent,
    double? billDiscountAmount,
    DateTime? billDate,
  }) {
    return EditBillState(
      originalBill: originalBill ?? this.originalBill,
      cartItems: cartItems ?? this.cartItems,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      amountReceived: amountReceived ?? this.amountReceived,
      paymentMode: paymentMode ?? this.paymentMode,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
      billDiscountPercent: billDiscountPercent ?? this.billDiscountPercent,
      billDiscountAmount: billDiscountAmount ?? this.billDiscountAmount,
      billDate: billDate ?? this.billDate,
    );
  }
}

