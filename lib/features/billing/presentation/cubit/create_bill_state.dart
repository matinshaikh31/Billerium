part of 'create_bill_cubit.dart';

class CreateBillState {
  final List<BillItemModel> cartItems;
  final double amountReceived;
  final String paymentMode;
  final bool isLoading;
  final String? message;

  // Bill-level discount fields
  final double billDiscountPercent;
  final double billDiscountAmount;

  CreateBillState({
    required this.cartItems,
    required this.amountReceived,
    required this.paymentMode,
    required this.isLoading,
    this.message,
    this.billDiscountPercent = 0,
    this.billDiscountAmount = 0,
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

  CreateBillState copyWith({
    List<BillItemModel>? cartItems,
    double? amountReceived,
    String? paymentMode,
    bool? isLoading,
    String? message,
    double? billDiscountPercent,
    double? billDiscountAmount,
  }) {
    return CreateBillState(
      cartItems: cartItems ?? this.cartItems,
      amountReceived: amountReceived ?? this.amountReceived,
      paymentMode: paymentMode ?? this.paymentMode,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      billDiscountPercent: billDiscountPercent ?? this.billDiscountPercent,
      billDiscountAmount: billDiscountAmount ?? this.billDiscountAmount,
    );
  }
}
