part of 'create_bill_cubit.dart';

class CreateBillState {
  final List<BillItemModel> cartItems;
  final double amountReceived;
  final String paymentMode;
  final bool isLoading;
  final String? message;

  CreateBillState({
    required this.cartItems,
    required this.amountReceived,
    required this.paymentMode,
    required this.isLoading,
    this.message,
  });

  factory CreateBillState.initial() {
    return CreateBillState(
      cartItems: [],
      amountReceived: 0,
      paymentMode: 'Cash',
      isLoading: false,
      message: null,
    );
  }

  // Calculate subtotal (no discounts)
  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Grand total (same as subtotal, no discounts)
  double get grandTotal {
    return subtotal;
  }

  // Calculate pending amount
  double get pendingAmount {
    return grandTotal - amountReceived;
  }

  CreateBillState copyWith({
    List<BillItemModel>? cartItems,
    double? amountReceived,
    String? paymentMode,
    bool? isLoading,
    String? message,
  }) {
    return CreateBillState(
      cartItems: cartItems ?? this.cartItems,
      amountReceived: amountReceived ?? this.amountReceived,
      paymentMode: paymentMode ?? this.paymentMode,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}
