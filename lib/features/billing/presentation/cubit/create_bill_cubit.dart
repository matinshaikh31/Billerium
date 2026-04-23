import 'package:billing_software/core/utils/helpers.dart';
import 'package:billing_software/features/billing/domain/repo/fbill_repository.dart';
import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:billing_software/features/customer/data/firebase_customer_analytics_repository.dart';
import 'package:billing_software/features/customer/data/firebase_customer_repository.dart';
import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/products/domain/repositories/product_repository.dart';
import 'package:billing_software/features/settings/domain/entity/setting_model.dart';
import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

part 'create_bill_state.dart';

class CreateBillCubit extends Cubit<CreateBillState> {
  final BillRepository billRepository;
  final ProductRepository productRepository;
  final FirebaseCustomerRepository customerRepository =
      FirebaseCustomerRepository();
  final FirebaseCustomerAnalyticsRepository analyticsRepository =
      FirebaseCustomerAnalyticsRepository();

  CreateBillCubit({
    required this.billRepository,
    required this.productRepository,
  }) : super(CreateBillState.initial());

  // Set tax rates from settings
  void setTaxRates(SettingModel settings) {
    emit(state.copyWith(cgstRate: settings.CGST, sgstRate: settings.SGST));
  }

  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerGstController = TextEditingController();
  final amountReceivedController = TextEditingController();
  final billDiscountPercentController = TextEditingController();
  final billDiscountAmountController = TextEditingController();

  // Add product to cart WITH product-level discount and category info
  void addProductToCart(
    ProductModel product,
    int quantity, {
    String? categoryName,
  }) {
    // Calculate price after product discount
    final discountPercent = product.discountPercent ?? 0;
    final priceAfterDiscount = product.finalPrice;
    final discountAmount = (product.price - priceAfterDiscount) * quantity;
    final itemTotal = priceAfterDiscount * quantity;

    final item = BillItemModel(
      productId: product.id,
      productName: product.name,
      categoryId: product.categoryId,
      categoryName: categoryName,
      price: product.price, // Original price
      quantity: quantity,
      discountPercent: discountPercent,
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
      final newPriceAfterDiscount = product.finalPrice;
      final newDiscountAmount =
          (product.price - newPriceAfterDiscount) * newQuantity;
      final newItemTotal = newPriceAfterDiscount * newQuantity;

      updatedCart[existingIndex] = BillItemModel(
        productId: existingItem.productId,
        productName: existingItem.productName,
        categoryId: existingItem.categoryId,
        categoryName: existingItem.categoryName,
        price: product.price,
        quantity: newQuantity,
        discountPercent: discountPercent,
        discountAmount: newDiscountAmount,
        itemTotal: newItemTotal,
      );
    } else {
      updatedCart = [...state.cartItems, item];
    }

    emit(state.copyWith(cartItems: updatedCart));
  }

  // Update item quantity (recalculate with discount)
  void updateItemQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItemFromCart(productId);
      return;
    }

    final updatedCart = state.cartItems.map((item) {
      if (item.productId == productId) {
        final priceAfterDiscount = item.discountPercent > 0
            ? item.price - (item.price * item.discountPercent / 100)
            : item.price;
        final newDiscountAmount =
            (item.price - priceAfterDiscount) * newQuantity;
        final newItemTotal = priceAfterDiscount * newQuantity;

        return BillItemModel(
          productId: item.productId,
          productName: item.productName,
          categoryId: item.categoryId,
          categoryName: item.categoryName,
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

  // Update payment mode
  void updatePaymentMode(String mode) {
    emit(state.copyWith(paymentMode: mode));
  }

  // Update amount received
  void updateAmountReceived(double amount) {
    emit(state.copyWith(amountReceived: amount));
  }

  // Update bill discount by percentage
  void updateBillDiscountPercent(double percent) {
    emit(
      state.copyWith(
        billDiscountPercent: percent,
        billDiscountAmount: 0, // Reset amount when using percent
      ),
    );
    billDiscountAmountController.clear();
  }

  // Update bill discount by fixed amount
  void updateBillDiscountAmount(double amount) {
    emit(
      state.copyWith(
        billDiscountAmount: amount,
        billDiscountPercent: 0, // Reset percent when using amount
      ),
    );
    billDiscountPercentController.clear();
  }

  // Update bill date
  void updateBillDate(DateTime date) {
    emit(state.copyWith(billDate: date));
  }

  // Update customer GST number
  void updateCustomerGstNumber(String gstNumber) {
    emit(state.copyWith(customerGstNumber: gstNumber));
  }

  // Select existing customer or create new one
  Future<void> selectOrCreateCustomer(String name, String phone) async {
    try {
      // Search for existing customer by phone number
      final customers = await customerRepository.searchCustomers(phone);

      CustomerModel? customer;

      if (customers.isNotEmpty) {
        // Customer exists - use existing customer
        customer = customers.first;

        // Update controllers
        customerNameController.text = customer.name;
        customerPhoneController.text = customer.phone;

        // Update state with customer info and balance
        emit(
          state.copyWith(
            customerId: customer.id,
            customerName: customer.name,
            customerPhone: customer.phone,
            customerGstNumber:
                customer.email, // Can add GST field to customer later
            customerBalance: customer.balance > 0
                ? customer.balance
                : 0, // Only positive balance can be used
          ),
        );
      } else {
        // Customer doesn't exist - create new customer
        final now = Timestamp.now();
        final newCustomer = CustomerModel(
          id: '',
          name: name.trim(),
          phone: phone.trim(),
          email: null,
          address: null,
          balance: 0,
          totalPurchases: 0,
          totalProfit: 0,
          orderCount: 0,
          createdAt: now,
          updatedAt: now,
        );

        final customerId = await customerRepository.createCustomer(newCustomer);

        // Update controllers
        customerNameController.text = name.trim();
        customerPhoneController.text = phone.trim();

        // Update state with new customer
        emit(
          state.copyWith(
            customerId: customerId,
            customerName: name.trim(),
            customerPhone: phone.trim(),
            customerBalance: 0,
          ),
        );
      }
    } catch (e) {
      // Error selecting/creating customer - silently fail
    }
  }

  // Clear customer selection (for walk-in customers)
  void clearCustomer() {
    customerNameController.clear();
    customerPhoneController.clear();
    customerGstController.clear();

    emit(
      state.copyWith(
        customerId: null,
        customerName: null,
        customerPhone: null,
        customerGstNumber: null,
        customerBalance: 0,
        balanceToUse: 0,
      ),
    );
  }

  // Set how much customer balance to use
  void setBalanceToUse(double amount) {
    final maxBalance = state.customerBalance;
    final maxNeeded = state.grandTotal;

    // Can't use more than available balance or more than bill amount
    final actualAmount = amount > maxBalance ? maxBalance : amount;
    final finalAmount = actualAmount > maxNeeded ? maxNeeded : actualAmount;

    emit(state.copyWith(balanceToUse: finalAmount));
  }

  // Create bill
  Future<void> createBill() async {
    emit(state.copyWith(isLoading: true, message: null));

    try {
      final String billNo = await generateBillNumber();

      // Calculate total payment (cash + balance used)
      final totalPaid = state.amountReceived + state.balanceToUse;

      // Determine bill status
      String billStatus;
      if (totalPaid >= state.grandTotal) {
        billStatus = 'Paid';
      } else if (totalPaid > 0) {
        billStatus = 'PartiallyPaid';
      } else {
        billStatus = 'Unpaid';
      }

      // Create payment record
      final List<PaymentModel> payments = [];
      if (state.amountReceived > 0) {
        payments.add(
          PaymentModel(
            id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
            amount: state.amountReceived,
            mode: state.paymentMode,
            paidAt: Timestamp.now(),
          ),
        );
      }

      // Convert selected bill date to Timestamp
      final billTimestamp = Timestamp.fromDate(state.billDate);

      // Create bill with all discount and tax calculations
      final bill = BillModel(
        id: '',
        billNo: billNo,
        items: state.cartItems,
        customerId: state.customerId, // Add customer ID
        customerName:
            state.customerName ??
            customerNameController.text.trim().toLowerCase(),
        customerPhone: state.customerPhone ?? customerPhoneController.text,
        customerGstNumber: state.customerGstNumber,
        totalBeforeDiscount: state.totalBeforeDiscount,
        subtotal: state.subtotal,
        totalDiscount: state.totalDiscount,
        cgst: state.cgst,
        sgst: state.sgst,
        totalTax: state.totalTax,
        billDiscountPercent: state.billDiscountPercent,
        billDiscountAmount: state.calculatedBillDiscount,
        finalAmount: state.grandTotal,
        amountPaid: totalPaid, // Total payment including balance used
        pendingAmount: state.grandTotal - totalPaid,
        status: billStatus,
        payments: payments,
        createdAt: Timestamp.now(), // Actual creation timestamp
        updatedAt: Timestamp.now(),
        billDate: billTimestamp, // User-selected bill date for analytics
      );

      // Save bill
      final billId = await billRepository.createBill(bill);

      // Create transaction
      if (state.amountReceived > 0) {
        final transaction = TransactionModel(
          id: '',
          billId: billId,
          billNo: billNo,
          customerId: state.customerId, // Add customer ID
          customerName: state.customerName ?? customerNameController.text,
          customerPhone: state.customerPhone ?? customerPhoneController.text,
          amount: state.amountReceived,
          mode: state.paymentMode,
          timestamp: Timestamp.now(),
        );

        await FBFireStore.transactions.add(transaction.toJson());
      }

      // Update customer balance and analytics if this is a regular customer
      if (state.customerId != null) {
        // Calculate balance change
        final double balanceChange = state.balanceToUse > 0
            ? -state
                  .balanceToUse // Deduct balance used
            : (state.grandTotal - totalPaid < 0
                  ? 0.0
                  : state.grandTotal - totalPaid); // Add unpaid amount as debt

        // Update customer balance
        if (balanceChange != 0) {
          await customerRepository.updateBalance(
            state.customerId!,
            -balanceChange,
          );
        }

        // Calculate profit (simplified - you can make this more accurate)
        final profit = state.totalTax; // Using tax as proxy for profit

        // Update customer analytics
        await customerRepository.updateAnalytics(
          customerId: state.customerId!,
          purchaseAmount: state.grandTotal,
          profit: profit,
        );

        // Update monthly analytics
        await analyticsRepository.updateMonthlyAnalytics(
          customerId: state.customerId!,
          billDate: state.billDate,
          billAmount: state.grandTotal,
          profit: profit,
          amountPaid: state.amountReceived,
          balanceUsed: state.balanceToUse,
        );
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
    customerGstController.clear();
    amountReceivedController.clear();
    billDiscountPercentController.clear();
    billDiscountAmountController.clear();

    emit(CreateBillState.initial());
  }

  @override
  Future<void> close() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerGstController.dispose();
    amountReceivedController.dispose();
    billDiscountPercentController.dispose();
    billDiscountAmountController.dispose();
    return super.close();
  }
}
