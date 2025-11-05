
// ===========================================
// 6. CREATE BILL STATE
// ============================================
// File: create_bill_state.dart

part of 'create_bill_cubit.dart';

class CreateBillState {
  final List<BillItemModel> cartItems;
  final String? customerName;
  final String? customerPhone;
  final double billDiscountPercent;
  final String billDiscountType; // 'Percentage', 'Amount'
  final double amountReceived;
  final String paymentMode;
  final String paymentStatus;
  final bool isLoading;
  final String? message;

  CreateBillState({
    required this.cartItems,
    this.customerName,
    this.customerPhone,
    required this.billDiscountPercent,
    required this.billDiscountType,
    required this.amountReceived,
    required this.paymentMode,
    required this.paymentStatus,
    required this.isLoading,
    this.message,
  });

  factory CreateBillState.initial() {
    return CreateBillState(
      cartItems: [],
      customerName: null,
      customerPhone: null,
      billDiscountPercent: 0,
      billDiscountType: 'Percentage',
      amountReceived: 0,
      paymentMode: 'Cash',
      paymentStatus: 'Pending',
      isLoading: false,
      message: null,
    );
  }

  // Calculate subtotal
  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Calculate total item discount
  double get totalItemDiscount {
    return cartItems.fold(0, (sum, item) => sum + item.discountAmount);
  }

  // Calculate bill discount
  double get billDiscountAmount {
    if (billDiscountType == 'Percentage') {
      return (subtotal - totalItemDiscount) * billDiscountPercent / 100;
    }
    return billDiscountPercent; // Direct amount
  }

  // Calculate grand total
  double get grandTotal {
    return subtotal - totalItemDiscount - billDiscountAmount;
  }

  // Calculate pending amount
  double get pendingAmount {
    return grandTotal - amountReceived;
  }

  CreateBillState copyWith({
    List<BillItemModel>? cartItems,
    String? customerName,
    String? customerPhone,
    double? billDiscountPercent,
    String? billDiscountType,
    double? amountReceived,
    String? paymentMode,
    String? paymentStatus,
    bool? isLoading,
    String? message,
    bool clearCustomer = false,
  }) {
    return CreateBillState(
      cartItems: cartItems ?? this.cartItems,
      customerName: clearCustomer ? null : (customerName ?? this.customerName),
      customerPhone: clearCustomer ? null : (customerPhone ?? this.customerPhone),
      billDiscountPercent: billDiscountPercent ?? this.billDiscountPercent,
      billDiscountType: billDiscountType ?? this.billDiscountType,
      amountReceived: amountReceived ?? this.amountReceived,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}

// ============================================
// 7. CREATE BILL CUBIT
// ============================================
// File: create_bill_cubit.dart

