import 'package:cloud_firestore/cloud_firestore.dart';

// Category Model
class CategoryModel {
  final String id;
  final String name;
  final double defaultDiscountPercent;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.defaultDiscountPercent,
    required this.createdAt,
    required this.updatedAt,
  });
}

// Product Model
class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final double? discountPercent;
  final String? sku;
  final int stockQty;
  final int qty;
  final double? lastPurchasePrice;
  final double? averagePurchasePrice;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    this.discountPercent,
    this.sku,
    required this.stockQty,
    required this.qty,
    this.lastPurchasePrice,
    this.averagePurchasePrice,
    required this.createdAt,
    required this.updatedAt,
  });
}

// Bill Item Model
class BillItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double discountPercent;
  final double discountAmount;
  final double itemTotal;

  const BillItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.discountPercent,
    required this.discountAmount,
    required this.itemTotal,
  });
}

// Payment Model
class PaymentModel {
  final String id;
  final double amount;
  final String mode;
  final Timestamp paidAt;

  const PaymentModel({
    required this.id,
    required this.amount,
    required this.mode,
    required this.paidAt,
  });
}

// Bill Model
class BillModel {
  final String id;
  final String billNo;
  final List<BillItemModel> items;
  final String? customerName;
  final String? customerPhone;
  final double subtotal;
  final double totalDiscount;
  final double totalTax;
  final double billDiscountPercent;
  final double billDiscountAmount;
  final double finalAmount;
  final double amountPaid;
  final double pendingAmount;
  final String status;
  final List<PaymentModel> payments;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const BillModel({
    required this.id,
    required this.billNo,
    required this.items,
    this.customerName,
    this.customerPhone,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalTax,
    required this.billDiscountPercent,
    required this.billDiscountAmount,
    required this.finalAmount,
    required this.amountPaid,
    required this.pendingAmount,
    required this.status,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
  });
}

// Transaction Model
class TransactionModel {
  final String id;
  final String billId;
  final String billNo;
  final String customerName;
  final String? customerPhone;
  final double amount;
  final String mode;
  final Timestamp timestamp;

  const TransactionModel({
    required this.id,
    required this.billId,
    required this.billNo,
    required this.customerName,
    this.customerPhone,
    required this.amount,
    required this.mode,
    required this.timestamp,
  });
}

// Analytics Model
class AnalyticsModel {
  final double totalSales;
  final int totalBills;
  final int totalProducts;
  final double totalPaidAmount;
  final double totalUnpaidAmount;
  final Map<String, double> monthlySales;
  final List<Map<String, dynamic>> topSellingProducts;
  final Timestamp lastUpdated;

  AnalyticsModel({
    required this.totalSales,
    required this.totalBills,
    required this.totalProducts,
    required this.totalPaidAmount,
    required this.totalUnpaidAmount,
    required this.monthlySales,
    required this.topSellingProducts,
    required this.lastUpdated,
  });
}

// Monthly Sales Model
class MonthlySalesModel {
  final String id;
  final double totalSales;
  final double totalPaid;
  final double totalPending;
  final int totalBills;
  final int totalProductsSold;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  MonthlySalesModel({
    required this.id,
    required this.totalSales,
    required this.totalPaid,
    required this.totalPending,
    required this.totalBills,
    required this.totalProductsSold,
    required this.createdAt,
    required this.updatedAt,
  });
}

// Purchase Model
class PurchaseModel {
  final String id;
  final String purchaseNo;
  final String? supplierName;
  final String? supplierPhone;
  final List<PurchaseItemModel> items;
  final double subtotal;
  final double totalTax;
  final double finalAmount;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  PurchaseModel({
    required this.id,
    required this.purchaseNo,
    this.supplierName,
    this.supplierPhone,
    required this.items,
    required this.subtotal,
    required this.totalTax,
    required this.finalAmount,
    required this.createdAt,
    required this.updatedAt,
  });
}

// Purchase Item Model
class PurchaseItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double purchasePrice;
  final double total;

  PurchaseItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
    required this.total,
  });
}

// Stock Ledger Model
class StockLedgerModel {
  final String id;
  final String productId;
  final String type;
  final int qtyChange;
  final int finalStock;
  final String referenceId;
  final Timestamp timestamp;

  StockLedgerModel({
    required this.id,
    required this.productId,
    required this.type,
    required this.qtyChange,
    required this.finalStock,
    required this.referenceId,
    required this.timestamp,
  });
}

// Profit Model
class ProfitModel {
  final String productId;
  final double totalPurchaseCost;
  final double totalSalesRevenue;
  final double totalProfit;
  final int unitsSold;

  ProfitModel({
    required this.productId,
    required this.totalPurchaseCost,
    required this.totalSalesRevenue,
    required this.totalProfit,
    required this.unitsSold,
  });
}

// Monthly Purchase Model
class MonthlyPurchaseModel {
  final String id;
  final double totalPurchaseAmount;
  final int totalItemsPurchased;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  MonthlyPurchaseModel({
    required this.id,
    required this.totalPurchaseAmount,
    required this.totalItemsPurchased,
    required this.createdAt,
    required this.updatedAt,
  });
}
