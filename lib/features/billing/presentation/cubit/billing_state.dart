part of 'billing_cubit.dart';

class BillingState extends Equatable {
  final bool isLoading;
  final String? message;
  final List<BillItemModel> cartItems;
  final String? customerName;
  final String? customerPhone;
  final double billDiscountPercent;
  final double billDiscountAmount;
  final Map<String, double> calculations;
  final List<BillModel> bills;
  final BillModel? currentBill;

  const BillingState({
    required this.isLoading,
    this.message,
    required this.cartItems,
    this.customerName,
    this.customerPhone,
    required this.billDiscountPercent,
    required this.billDiscountAmount,
    required this.calculations,
    required this.bills,
    this.currentBill,
  });

  factory BillingState.initial() {
    return const BillingState(
      isLoading: false,
      message: null,
      cartItems: [],
      customerName: null,
      customerPhone: null,
      billDiscountPercent: 0,
      billDiscountAmount: 0,
      calculations: {},
      bills: [],
      currentBill: null,
    );
  }

  factory BillingState.loading() {
    return const BillingState(
      isLoading: true,
      message: null,
      cartItems: [],
      customerName: null,
      customerPhone: null,
      billDiscountPercent: 0,
      billDiscountAmount: 0,
      calculations: {},
      bills: [],
      currentBill: null,
    );
  }

  factory BillingState.error(String message) {
    return BillingState(
      isLoading: false,
      message: message,
      cartItems: const [],
      customerName: null,
      customerPhone: null,
      billDiscountPercent: 0,
      billDiscountAmount: 0,
      calculations: const {},
      bills: const [],
      currentBill: null,
    );
  }

  factory BillingState.success(String message, List<BillModel> bills) {
    return BillingState(
      isLoading: false,
      message: message,
      cartItems: const [],
      customerName: null,
      customerPhone: null,
      billDiscountPercent: 0,
      billDiscountAmount: 0,
      calculations: const {},
      bills: bills,
      currentBill: null,
    );
  }

  BillingState copyWith({
    bool? isLoading,
    String? message,
    List<BillItemModel>? cartItems,
    String? customerName,
    String? customerPhone,
    double? billDiscountPercent,
    double? billDiscountAmount,
    Map<String, double>? calculations,
    List<BillModel>? bills,
    BillModel? currentBill,
    bool clearMessage = false,
    bool clearCustomer = false,
    bool clearCart = false,
  }) {
    return BillingState(
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
      cartItems: clearCart ? [] : (cartItems ?? this.cartItems),
      customerName: clearCustomer ? null : (customerName ?? this.customerName),
      customerPhone:
          clearCustomer ? null : (customerPhone ?? this.customerPhone),
      billDiscountPercent: billDiscountPercent ?? this.billDiscountPercent,
      billDiscountAmount: billDiscountAmount ?? this.billDiscountAmount,
      calculations: calculations ?? this.calculations,
      bills: bills ?? this.bills,
      currentBill: currentBill ?? this.currentBill,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        message,
        cartItems,
        customerName,
        customerPhone,
        billDiscountPercent,
        billDiscountAmount,
        calculations,
        bills,
        currentBill,
      ];
}

