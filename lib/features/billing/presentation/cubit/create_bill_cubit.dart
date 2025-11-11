import 'package:billing_software/features/billing/domain/repo/fbill_repository.dart';
import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/products/domain/repositories/product_repository.dart';
import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

part 'create_bill_state.dart';

class CreateBillCubit extends Cubit<CreateBillState> {
  final BillRepository billRepository;
  final ProductRepository productRepository;

  CreateBillCubit({
    required this.billRepository,
    required this.productRepository,
  }) : super(CreateBillState.initial());

  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final amountReceivedController = TextEditingController();

  // Add product to cart (without discount)
  void addProductToCart(ProductModel product, int quantity) {
    final itemTotal = product.price * quantity;

    final item = BillItemModel(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: quantity,
      discountPercent: 0,
      discountAmount: 0,
      itemTotal: itemTotal,
    );

    final existingIndex = state.cartItems.indexWhere(
      (i) => i.productId == product.id,
    );

    List<BillItemModel> updatedCart;
    if (existingIndex != -1) {
      // Update quantity
      updatedCart = List.from(state.cartItems);
      final existingItem = updatedCart[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      final newItemTotal = product.price * newQuantity;

      updatedCart[existingIndex] = BillItemModel(
        productId: existingItem.productId,
        productName: existingItem.productName,
        price: existingItem.price,
        quantity: newQuantity,
        discountPercent: 0,
        discountAmount: 0,
        itemTotal: newItemTotal,
      );
    } else {
      updatedCart = [...state.cartItems, item];
    }

    emit(state.copyWith(cartItems: updatedCart));
  }

  // Update item quantity
  void updateItemQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItemFromCart(productId);
      return;
    }

    final updatedCart = state.cartItems.map((item) {
      if (item.productId == productId) {
        final newItemTotal = item.price * newQuantity;

        return BillItemModel(
          productId: item.productId,
          productName: item.productName,
          price: item.price,
          quantity: newQuantity,
          discountPercent: 0,
          discountAmount: 0,
          itemTotal: newItemTotal,
        );
      }
      return item;
    }).toList();

    emit(state.copyWith(cartItems: updatedCart));
  }

  // Remove item from cart
  void removeItemFromCart(String productId) {
    final updatedCart = state.cartItems
        .where((item) => item.productId != productId)
        .toList();
    emit(state.copyWith(cartItems: updatedCart));
  }

  // Update payment mode
  void updatePaymentMode(String mode) {
    emit(state.copyWith(paymentMode: mode));
  }

  // Update amount received (for real-time pending amount calculation)
  void updateAmountReceived(double amount) {
    emit(state.copyWith(amountReceived: amount));
  }

  // Create bill
  Future<void> createBill() async {
    // final validationError = validateForm();
    // if (validationError != null) {
    //   emit(state.copyWith(message: validationError));
    //   return;
    // }

    emit(state.copyWith(isLoading: true, message: null));

    try {
      // Determine bill status
      String billStatus;
      if (state.amountReceived >= state.grandTotal) {
        billStatus = 'Paid';
      } else if (state.amountReceived > 0) {
        billStatus = 'PartiallyPaid';
      } else {
        billStatus = 'Unpaid';
      }

      // Create payment record
      final List<PaymentModel> payments = [];
      if (state.amountReceived > 0) {
        payments.add(
          PaymentModel(
            id: const Uuid().v4(),
            amount: state.amountReceived,
            mode: state.paymentMode,
            paidAt: Timestamp.now(),
          ),
        );
      }

      // Create bill
      final bill = BillModel(
        id: '',
        items: state.cartItems,
        customerName: customerNameController.text,
        customerPhone: customerPhoneController.text,
        subtotal: state.subtotal,
        totalDiscount: 0,
        totalTax: 0,
        billDiscountPercent: 0,
        billDiscountAmount: 0,
        finalAmount: state.grandTotal,
        amountPaid: state.amountReceived,
        pendingAmount: state.pendingAmount,
        status: billStatus,
        payments: payments,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      // Save bill
      final billId = await billRepository.createBill(bill);
        
      // Create transaction
      if (state.amountReceived > 0) {
        final transaction = TransactionModel(
          id: '',
          billId: billId,
          customerName: customerNameController.text,
          customerPhone: customerPhoneController.text,
          amount: state.amountReceived,
          mode: state.paymentMode,
          timestamp: Timestamp.now(),
        );

        // Save transaction to Firestore
        await FBFireStore.transactions.add(transaction.toJson());
      }

      emit(
        state.copyWith(isLoading: false, message: 'Bill created successfully'),
      );

      // Reset form after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      clearBill();
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: ${e.toString()}'));
    }
  }

  // Clear bill
  void clearBill() {
    customerNameController.clear();
    customerPhoneController.clear();
    amountReceivedController.clear();

    emit(CreateBillState.initial());
  }

  @override
  Future<void> close() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    amountReceivedController.dispose();
    return super.close();
  }
}
