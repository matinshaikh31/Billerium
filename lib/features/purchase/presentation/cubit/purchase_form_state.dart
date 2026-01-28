import 'package:billing_software/features/purchase/domain/entity/purchase_item_model.dart';
import 'package:equatable/equatable.dart';

class PurchaseFormState extends Equatable {
  final List<PurchaseItemModel> items;
  final String? supplierName;
  final String? supplierPhone;
  final double subtotal;
  final double totalTax;
  final double otherExpense;
  final double finalAmount;
  final bool isLoading;
  final String? error;

  const PurchaseFormState({
    this.items = const [],
    this.supplierName,
    this.supplierPhone,
    this.subtotal = 0,
    this.totalTax = 0,
    this.otherExpense = 0,
    this.finalAmount = 0,
    this.isLoading = false,
    this.error,
  });

  PurchaseFormState copyWith({
    List<PurchaseItemModel>? items,
    String? supplierName,
    String? supplierPhone,
    double? subtotal,
    double? totalTax,
    double? otherExpense,
    double? finalAmount,
    bool? isLoading,
    String? error,
  }) {
    return PurchaseFormState(
      items: items ?? this.items,
      supplierName: supplierName ?? this.supplierName,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      subtotal: subtotal ?? this.subtotal,
      totalTax: totalTax ?? this.totalTax,
      otherExpense: otherExpense ?? this.otherExpense,
      finalAmount: finalAmount ?? this.finalAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    items,
    supplierName,
    supplierPhone,
    subtotal,
    totalTax,
    otherExpense,
    finalAmount,
    isLoading,
    error,
  ];
}
