import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:billing_software/features/billing/domain/repo/fbill_repository.dart';
import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/settings/domain/entity/setting_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

part 'edit_bill_state.dart';

class EditBillCubit extends Cubit<EditBillState> {
  final BillRepository billRepository;

  EditBillCubit({required this.billRepository})
    : super(EditBillState.initial());

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

  /// Initialize the cubit with an existing bill for editing
  /// Also enriches bill items with category data from products if missing
  Future<void> loadBill(BillModel bill, List<CategoryModel> categories) async {
    customerNameController.text = bill.customerName ?? '';
    customerPhoneController.text = bill.customerPhone ?? '';
    customerGstController.text = bill.customerGstNumber ?? '';
    amountReceivedController.text = bill.amountPaid.toStringAsFixed(2);

    if (bill.billDiscountPercent > 0) {
      billDiscountPercentController.text = bill.billDiscountPercent.toString();
    }
    if (bill.billDiscountAmount > 0) {
      billDiscountAmountController.text = bill.billDiscountAmount.toString();
    }

    // Enrich items with category data if missing
    List<BillItemModel> enrichedItems = [];
    for (var item in bill.items) {
      if (item.categoryId == null || item.categoryName == null) {
        // Fetch product to get category info
        try {
          final productDoc = await FirebaseFirestore.instance
              .collection('products')
              .doc(item.productId)
              .get();

          if (productDoc.exists) {
            final productData = productDoc.data()!;
            final categoryId = productData['categoryId'] as String?;
            String? categoryName;

            if (categoryId != null) {
              // Find category name from the passed categories list
              final category = categories.firstWhere(
                (cat) => cat.id == categoryId,
                orElse: () => CategoryModel(
                  id: '',
                  name: 'Unknown',
                  defaultDiscountPercent: 0,
                  createdAt: Timestamp.now(),
                  updatedAt: Timestamp.now(),
                ),
              );
              categoryName = category.name;
            }

            enrichedItems.add(
              item.copyWith(
                categoryId: categoryId ?? item.categoryId,
                categoryName: categoryName ?? item.categoryName,
              ),
            );
          } else {
            enrichedItems.add(item);
          }
        } catch (e) {
          enrichedItems.add(item);
        }
      } else {
        enrichedItems.add(item);
      }
    }

    emit(
      EditBillState(
        originalBill: bill,
        cartItems: enrichedItems,
        customerName: bill.customerName,
        customerPhone: bill.customerPhone,
        customerGstNumber: bill.customerGstNumber,
        amountReceived: bill.amountPaid,
        paymentMode: bill.payments.isNotEmpty
            ? bill.payments.last.mode
            : 'Cash',
        isLoading: false,
        billDiscountPercent: bill.billDiscountPercent,
        billDiscountAmount: bill.billDiscountAmount,
        billDate: bill.billDate?.toDate() ?? bill.createdAt.toDate(),
      ),
    );
  }

  /// Add product to cart with category info
  void addProductToCart(
    ProductModel product,
    int quantity, {
    String? categoryName,
  }) {
    final discountPercent = product.discountPercent ?? 0;
    final priceAfterDiscount = product.finalPrice;
    final discountAmount = (product.price - priceAfterDiscount) * quantity;
    final itemTotal = priceAfterDiscount * quantity;

    final item = BillItemModel(
      productId: product.id,
      productName: product.name,
      categoryId: product.categoryId,
      categoryName: categoryName,
      price: product.price,
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

  /// Update item quantity
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

  /// Remove item from cart
  void removeItemFromCart(String productId) {
    final updatedCart = state.cartItems
        .where((item) => item.productId != productId)
        .toList();
    emit(state.copyWith(cartItems: updatedCart));
  }

  void updatePaymentMode(String mode) {
    emit(state.copyWith(paymentMode: mode));
  }

  void updateAmountReceived(double amount) {
    emit(state.copyWith(amountReceived: amount));
  }

  void updateBillDiscountPercent(double percent) {
    emit(state.copyWith(billDiscountPercent: percent, billDiscountAmount: 0));
    billDiscountAmountController.clear();
  }

  void updateBillDiscountAmount(double amount) {
    emit(state.copyWith(billDiscountAmount: amount, billDiscountPercent: 0));
    billDiscountPercentController.clear();
  }

  void updateBillDate(DateTime date) {
    emit(state.copyWith(billDate: date));
  }

  void updateCustomerName(String name) {
    emit(state.copyWith(customerName: name));
  }

  void updateCustomerPhone(String phone) {
    emit(state.copyWith(customerPhone: phone));
  }

  void updateCustomerGstNumber(String gstNumber) {
    emit(state.copyWith(customerGstNumber: gstNumber));
  }

  /// Save the edited bill
  Future<bool> saveBill() async {
    if (state.originalBill == null) {
      emit(state.copyWith(message: 'No bill to edit'));
      return false;
    }

    if (state.cartItems.isEmpty) {
      emit(state.copyWith(message: 'Cart is empty'));
      return false;
    }

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

      // Create payment records
      final List<PaymentModel> payments = [];
      if (state.amountReceived > 0) {
        payments.add(
          PaymentModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            amount: state.amountReceived,
            mode: state.paymentMode,
            paidAt: Timestamp.now(),
          ),
        );
      }

      final billTimestamp = Timestamp.fromDate(state.billDate);

      // Create updated bill with tax calculations
      final updatedBill = BillModel(
        id: state.originalBill!.id,
        billNo: state.originalBill!.billNo,
        items: state.cartItems,
        customerName: customerNameController.text.trim().isEmpty
            ? null
            : customerNameController.text.trim().toLowerCase(),
        customerPhone: customerPhoneController.text.trim().isEmpty
            ? null
            : customerPhoneController.text.trim(),
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
        amountPaid: state.amountReceived,
        pendingAmount: state.pendingAmount,
        status: billStatus,
        payments: payments,
        createdAt: state.originalBill!.createdAt,
        updatedAt: Timestamp.now(),
        billDate: billTimestamp,
      );

      // Call repository to update with analytics
      await billRepository.updateBillWithAnalytics(
        state.originalBill!,
        updatedBill,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          message: 'Bill updated successfully',
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Failed to update bill: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  void reset() {
    customerNameController.clear();
    customerPhoneController.clear();
    customerGstController.clear();
    amountReceivedController.clear();
    billDiscountPercentController.clear();
    billDiscountAmountController.clear();
    emit(EditBillState.initial());
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
