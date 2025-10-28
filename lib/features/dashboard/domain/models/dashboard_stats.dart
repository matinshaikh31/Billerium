import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final double dailySales;
  final double monthlySales;
  final double yearlySales;
  final int paidBillsCount;
  final int partiallyPaidBillsCount;
  final int unpaidBillsCount;
  final int totalProducts;
  final int totalCategories;
  final int lowStockCount;

  const DashboardStats({
    required this.dailySales,
    required this.monthlySales,
    required this.yearlySales,
    required this.paidBillsCount,
    required this.partiallyPaidBillsCount,
    required this.unpaidBillsCount,
    required this.totalProducts,
    required this.totalCategories,
    required this.lowStockCount,
  });

  @override
  List<Object?> get props => [
        dailySales,
        monthlySales,
        yearlySales,
        paidBillsCount,
        partiallyPaidBillsCount,
        unpaidBillsCount,
        totalProducts,
        totalCategories,
        lowStockCount,
      ];
}

