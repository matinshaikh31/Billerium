class ProfitModel {
  final String productId;
  final double totalPurchaseCost;
  final double totalSalesRevenue;
  final double totalProfit;
  final int unitsSold;

  const ProfitModel({
    required this.productId,
    required this.totalPurchaseCost,
    required this.totalSalesRevenue,
    required this.totalProfit,
    required this.unitsSold,
  });

  factory ProfitModel.fromJson(Map<String, dynamic> json, String productId) {
    return ProfitModel(
      productId: productId,
      totalPurchaseCost: (json['totalPurchaseCost'] ?? 0).toDouble(),
      totalSalesRevenue: (json['totalSalesRevenue'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
      unitsSold: json['unitsSold'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPurchaseCost': totalPurchaseCost,
      'totalSalesRevenue': totalSalesRevenue,
      'totalProfit': totalProfit,
      'unitsSold': unitsSold,
    };
  }

  ProfitModel copyWith({
    String? productId,
    double? totalPurchaseCost,
    double? totalSalesRevenue,
    double? totalProfit,
    int? unitsSold,
  }) {
    return ProfitModel(
      productId: productId ?? this.productId,
      totalPurchaseCost: totalPurchaseCost ?? this.totalPurchaseCost,
      totalSalesRevenue: totalSalesRevenue ?? this.totalSalesRevenue,
      totalProfit: totalProfit ?? this.totalProfit,
      unitsSold: unitsSold ?? this.unitsSold,
    );
  }
}

