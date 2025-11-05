import 'package:billing_software/features/billing/data/firebase_bill_repository.dart';
import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/products/domain/repositories/product_repository.dart';
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
  final billDiscountController = TextEditingController();
  final amountReceivedController = TextEditingController();

  // Add product to cart
  void addProductToCart(ProductModel product, int quantity) {
    final discountAmount =
        (product.price * quantity) * (product.discountPercent ?? 0) / 100;
    final itemTotal = (product.price * quantity) - discountAmount;

    final item = BillItemModel(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: quantity,
      discountPercent: product.discountPercent ?? 0,
      discountAmount: discountAmount,
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
      final newDiscountAmount =
          (product.price * newQuantity) * (product.discountPercent ?? 0) / 100;
      final newItemTotal = (product.price * newQuantity) - newDiscountAmount;

      updatedCart[existingIndex] = BillItemModel(
        productId: existingItem.productId,
        productName: existingItem.productName,
        price: existingItem.price,
        quantity: newQuantity,
        discountPercent: existingItem.discountPercent,
        discountAmount: newDiscountAmount,
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
        final newDiscountAmount =
            (item.price * newQuantity) * item.discountPercent / 100;
        final newItemTotal = (item.price * newQuantity) - newDiscountAmount;

        return BillItemModel(
          productId: item.productId,
          productName: item.productName,
          price: item.price,
          quantity: newQuantity,
          discountPercent: item.discountPercent,
          discountAmount: newDiscountAmount,
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

  // Update customer details
  void updateCustomerName(String name) {
    customerNameController.text = name;
    emit(state.copyWith(customerName: name));
  }

  void updateCustomerPhone(String phone) {
    customerPhoneController.text = phone;
    emit(state.copyWith(customerPhone: phone));
  }

  // Update bill discount
  void updateBillDiscount(double value) {
    billDiscountController.text = value.toString();
    emit(state.copyWith(billDiscountPercent: value));
  }

  void updateBillDiscountType(String type) {
    emit(state.copyWith(billDiscountType: type));
  }

  // Update payment details
  void updateAmountReceived(double amount) {
    amountReceivedController.text = amount.toString();
    emit(state.copyWith(amountReceived: amount));
  }

  void updatePaymentMode(String mode) {
    emit(state.copyWith(paymentMode: mode));
  }

  void updatePaymentStatus(String status) {
    emit(state.copyWith(paymentStatus: status));
  }

  // Create bill
  Future<void> createBill() async {
    if (state.cartItems.isEmpty) {
      emit(state.copyWith(message: 'Please add items to cart'));
      return;
    }

    emit(state.copyWith(isLoading: true, message: null));

    try {
      String billStatus;
      if (state.amountReceived >= state.grandTotal) {
        billStatus = 'Paid';
      } else if (state.amountReceived > 0) {
        billStatus = 'PartiallyPaid';
      } else {
        billStatus = 'Unpaid';
      }

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

      final bill = BillModel(
        id: '',
        items: state.cartItems,
        customerName: state.customerName,
        customerPhone: state.customerPhone,
        subtotal: state.subtotal,
        totalDiscount: state.totalItemDiscount,
        totalTax: 0, // Add tax logic if needed
        billDiscountPercent: state.billDiscountPercent,
        billDiscountAmount: state.billDiscountAmount,
        finalAmount: state.grandTotal,
        amountPaid: state.amountReceived,
        pendingAmount: state.pendingAmount,
        status: billStatus,
        payments: payments,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await billRepository.createBill(bill);

      emit(
        state.copyWith(isLoading: false, message: 'Bill created successfully'),
      );

      // Reset form
      clearBill();
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: ${e.toString()}'));
    }
  }

  // Clear bill
  void clearBill() {
    customerNameController.clear();
    customerPhoneController.clear();
    billDiscountController.clear();
    amountReceivedController.clear();

    emit(CreateBillState.initial());
  }

  @override
  Future<void> close() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    billDiscountController.dispose();
    amountReceivedController.dispose();
    return super.close();
  }
}
