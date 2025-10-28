import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/bill_model.dart';
import '../../domain/models/bill_item_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../../products/domain/models/product_model.dart';
import '../../../../core/utils/billing_calculator.dart';

part 'billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  final BillRepository _repository;

  BillingCubit(this._repository) : super(BillingState.initial());

  // Load all bills
  Future<void> loadBills() async {
    try {
      emit(state.copyWith(isLoading: true));
      final bills = await _repository.getAllBills();
      emit(state.copyWith(isLoading: false, bills: bills));
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  // Add product to cart
  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = state.cartItems.indexWhere(
      (item) => item.productId == product.id,
    );

    List<BillItemModel> updatedCart;

    if (existingIndex >= 0) {
      // Update quantity if product already in cart
      updatedCart = List.from(state.cartItems);
      final existingItem = updatedCart[existingIndex];
      updatedCart[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item to cart
      final newItem = BillItemModel(
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        price: product.price,
        discountPercent: product.discountPercent ?? 0,
        taxPercent: product.taxPercent,
      );
      updatedCart = [...state.cartItems, newItem];
    }

    _updateCartAndCalculations(updatedCart);
  }

  // Update cart item quantity
  void updateCartItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final updatedCart = state.cartItems.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    _updateCartAndCalculations(updatedCart);
  }

  // Remove item from cart
  void removeFromCart(String productId) {
    final updatedCart = state.cartItems
        .where((item) => item.productId != productId)
        .toList();
    _updateCartAndCalculations(updatedCart);
  }

  // Clear cart
  void clearCart() {
    emit(
      state.copyWith(
        clearCart: true,
        clearCustomer: true,
        billDiscountPercent: 0,
        billDiscountAmount: 0,
        calculations: const {},
      ),
    );
  }

  // Set customer info
  void setCustomerInfo(String? name, String? phone) {
    emit(state.copyWith(customerName: name, customerPhone: phone));
  }

  // Set bill discount
  void setBillDiscount({double percent = 0, double amount = 0}) {
    emit(
      state.copyWith(billDiscountPercent: percent, billDiscountAmount: amount),
    );
    _recalculate();
  }

  // Private method to update cart and recalculate
  void _updateCartAndCalculations(List<BillItemModel> cartItems) {
    emit(state.copyWith(cartItems: cartItems));
    _recalculate();
  }

  // Recalculate totals
  void _recalculate() {
    final calculations = BillingCalculator.calculateBillTotals(
      items: state.cartItems,
      billDiscountPercent: state.billDiscountPercent,
      billDiscountFlat: state.billDiscountAmount,
    );

    emit(state.copyWith(calculations: calculations));
  }

  // Create bill
  Future<void> createBill({
    required double amountPaid,
    required String paymentMode,
  }) async {
    try {
      if (state.cartItems.isEmpty) {
        emit(state.copyWith(message: 'Cart is empty'));
        return;
      }

      emit(state.copyWith(isLoading: true));

      final finalAmount = state.calculations['finalAmount'] ?? 0;
      final status = BillingCalculator.getBillStatus(finalAmount, amountPaid);
      final pendingAmount = BillingCalculator.getPendingAmount(
        finalAmount,
        amountPaid,
      );

      final payment = PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amountPaid,
        mode: paymentMode,
        timestamp: DateTime.now(),
      );

      final bill = BillModel(
        id: '',
        items: state.cartItems,
        customerName: state.customerName,
        customerPhone: state.customerPhone,
        subtotal: state.calculations['subtotal'] ?? 0,
        totalDiscount: state.calculations['totalDiscount'] ?? 0,
        totalTax: state.calculations['totalTax'] ?? 0,
        billDiscountPercent: state.billDiscountPercent,
        billDiscountAmount: state.calculations['billDiscountAmount'] ?? 0,
        finalAmount: finalAmount,
        amountPaid: amountPaid,
        pendingAmount: pendingAmount,
        status: status,
        payments: [payment],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createBill(bill);

      // Reload bills and clear cart
      final bills = await _repository.getAllBills();
      emit(BillingState.success('Bill created successfully', bills));
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  // Add payment to existing bill
  Future<void> addPayment({
    required String billId,
    required double amount,
    required String mode,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));

      final payment = PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        mode: mode,
        timestamp: DateTime.now(),
      );

      await _repository.addPayment(billId, payment);

      final bills = await _repository.getAllBills();
      emit(
        state.copyWith(
          isLoading: false,
          bills: bills,
          message: 'Payment added successfully',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  // Get bill by ID
  Future<void> getBillById(String billId) async {
    try {
      emit(state.copyWith(isLoading: true));
      final bill = await _repository.getBillById(billId);
      emit(state.copyWith(isLoading: false, currentBill: bill));
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }
}
