# 📊 Analytics & Reports - Complete Implementation Plan

## 🎯 **Requirements:**

1. **Bill CRUD with Analytics** - Edit, Update, Delete bills + update analytics
2. **Purchase Analytics** - Track purchase metrics (already partially done)
3. **Sale Analytics** - Track sale metrics (already done)
4. **Reports** - Generate sale and purchase reports
5. **Optimized Analytics** - Don't fetch all data, use aggregated models

---

## 📋 **Current State Analysis:**

### ✅ **Already Implemented:**

1. **MonthlySalesModel** - Tracks monthly sales
   - totalSales, totalPaid, totalPending
   - totalBills, totalProductsSold
   - ✅ Updates on bill create
   - ✅ Updates on payment add

2. **MonthlyPurchaseModel** - Tracks monthly purchases
   - totalPurchaseAmount, totalItemsPurchased
   - ✅ Model exists
   - ⚠️ Not updating on purchase create

3. **ProfitModel** - Tracks per-product profit
   - totalPurchaseCost, totalSalesRevenue, totalProfit
   - ✅ Updates on sale
   - ✅ Updates on purchase

4. **StockLedgerModel** - Audit trail
   - ✅ Tracks all stock movements

### ❌ **Missing:**

1. **Bill Edit/Delete** - No analytics update
2. **Purchase Edit/Delete** - No analytics update
3. **Reports Generation** - No report models or UI
4. **Aggregated Analytics** - Fetching all data instead of aggregates

---

## 🔧 **Implementation Plan:**

### **Phase 1: Bill CRUD with Analytics** ⏳

#### 1.1 Add Delete Bill Method
**File:** `lib/features/billing/data/firebase_bill_repository.dart`

```dart
@override
Future<void> deleteBill(String billId) async {
  try {
    // 1. Get bill data
    final billDoc = await billsCollectionRef.doc(billId).get();
    final bill = BillModel.fromJson(billDoc.data()!, billId);
    
    // 2. Reverse stock changes
    await _reverseStockChanges(bill.items, billId);
    
    // 3. Reverse profit tracking
    await _reverseProfitTracking(bill.items);
    
    // 4. Update analytics (subtract)
    await analyticsRepo.updateAnalyticsOnBillDelete(bill);
    
    // 5. Delete bill
    await billsCollectionRef.doc(billId).delete();
    
    // 6. Delete related transactions
    await _deleteRelatedTransactions(billId);
  } catch (e) {
    throw Exception('Failed to delete bill: $e');
  }
}
```

#### 1.2 Add Edit Bill Method
**File:** `lib/features/billing/data/firebase_bill_repository.dart`

```dart
@override
Future<void> editBill(String billId, BillModel newBill) async {
  try {
    // 1. Get old bill
    final oldBillDoc = await billsCollectionRef.doc(billId).get();
    final oldBill = BillModel.fromJson(oldBillDoc.data()!, billId);
    
    // 2. Calculate differences
    final itemsDiff = _calculateItemsDifference(oldBill.items, newBill.items);
    
    // 3. Update stock based on differences
    await _updateStockForEdit(itemsDiff, billId);
    
    // 4. Update profit tracking
    await _updateProfitForEdit(oldBill.items, newBill.items);
    
    // 5. Update analytics
    await analyticsRepo.updateAnalyticsOnBillEdit(oldBill, newBill);
    
    // 6. Update bill
    await updateBill(newBill.copyWith(updatedAt: Timestamp.now()));
  } catch (e) {
    throw Exception('Failed to edit bill: $e');
  }
}
```

#### 1.3 Add Analytics Methods
**File:** `lib/features/analytics/data/firebase_analytics_repo.dart`

```dart
// Delete bill analytics
Future<void> updateAnalyticsOnBillDelete(BillModel bill) async {
  final monthKey = _monthKeyFromTimestamp(bill.createdAt);
  final docRef = analyticsRef.doc(monthKey);
  
  await docRef.update({
    'totalSales': FieldValue.increment(-bill.finalAmount),
    'totalPaid': FieldValue.increment(-bill.amountPaid),
    'totalPending': FieldValue.increment(-bill.pendingAmount),
    'totalBills': FieldValue.increment(-1),
    'totalProductsSold': FieldValue.increment(
      -bill.items.fold(0, (sum, item) => sum + item.quantity),
    ),
    'updatedAt': Timestamp.now(),
  });
}

// Edit bill analytics
Future<void> updateAnalyticsOnBillEdit(
  BillModel oldBill,
  BillModel newBill,
) async {
  final monthKey = _monthKeyFromTimestamp(oldBill.createdAt);
  final docRef = analyticsRef.doc(monthKey);
  
  final salesDiff = newBill.finalAmount - oldBill.finalAmount;
  final paidDiff = newBill.amountPaid - oldBill.amountPaid;
  final pendingDiff = newBill.pendingAmount - oldBill.pendingAmount;
  final productsDiff = newBill.items.fold(0, (sum, item) => sum + item.quantity) -
      oldBill.items.fold(0, (sum, item) => sum + item.quantity);
  
  await docRef.update({
    'totalSales': FieldValue.increment(salesDiff),
    'totalPaid': FieldValue.increment(paidDiff),
    'totalPending': FieldValue.increment(pendingDiff),
    'totalProductsSold': FieldValue.increment(productsDiff),
    'updatedAt': Timestamp.now(),
  });
}
```

---

### **Phase 2: Purchase CRUD with Analytics** ⏳

#### 2.1 Update Purchase Analytics on Create
**File:** `lib/features/purchase/data/firebase_purchase_repository.dart`

```dart
// Add to createPurchase method
await _updateMonthlyPurchaseAnalytics(purchase);

// New method
Future<void> _updateMonthlyPurchaseAnalytics(PurchaseModel purchase) async {
  final monthKey = _monthKeyFromTimestamp(purchase.createdAt);
  final docRef = FBFireStore.monthlyPurchases.doc(monthKey);
  
  final docSnap = await docRef.get();
  
  if (!docSnap.exists) {
    final newDoc = MonthlyPurchaseModel(
      id: monthKey,
      totalPurchaseAmount: purchase.finalAmount,
      totalItemsPurchased: purchase.items.fold(
        0,
        (sum, item) => sum + item.quantity,
      ),
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
    await docRef.set(newDoc.toJson());
  } else {
    await docRef.update({
      'totalPurchaseAmount': FieldValue.increment(purchase.finalAmount),
      'totalItemsPurchased': FieldValue.increment(
        purchase.items.fold(0, (sum, item) => sum + item.quantity),
      ),
      'updatedAt': Timestamp.now(),
    });
  }
}
```

#### 2.2 Add Delete Purchase with Analytics
```dart
@override
Future<void> deletePurchase(String id) async {
  try {
    // 1. Get purchase
    final purchase = await getPurchaseById(id);
    if (purchase == null) return;
    
    // 2. Reverse stock changes
    await _reverseStockChanges(purchase.items, id);
    
    // 3. Update monthly analytics (subtract)
    await _updateMonthlyPurchaseAnalyticsOnDelete(purchase);
    
    // 4. Delete purchase
    await FBFireStore.purchases.doc(id).delete();
  } catch (e) {
    throw Exception('Failed to delete purchase: $e');
  }
}
```

---

### **Phase 3: Reports Generation** ⏳

#### 3.1 Create Report Models

**SalesReportModel:**
```dart
class SalesReportModel {
  final String period; // "2025-12" or "2025"
  final double totalRevenue;
  final double totalPaid;
  final double totalPending;
  final int totalBills;
  final int totalProductsSold;
  final List<TopSellingProduct> topProducts;
  final List<DailySales> dailyBreakdown;
  
  // Methods
  double get averageBillValue => totalBills > 0 ? totalRevenue / totalBills : 0;
  double get collectionRate => totalRevenue > 0 ? (totalPaid / totalRevenue) * 100 : 0;
}
```

**PurchaseReportModel:**
```dart
class PurchaseReportModel {
  final String period;
  final double totalPurchaseAmount;
  final int totalItemsPurchased;
  final int totalPurchases;
  final List<TopSupplier> topSuppliers;
  final List<DailyPurchases> dailyBreakdown;
  
  // Methods
  double get averagePurchaseValue => totalPurchases > 0 ? totalPurchaseAmount / totalPurchases : 0;
}
```

**ProfitReportModel:**
```dart
class ProfitReportModel {
  final String period;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMargin;
  final List<ProductProfit> topProfitableProducts;
}
```

#### 3.2 Create Report Repository
**File:** `lib/features/reports/data/firebase_reports_repository.dart`

```dart
class FirebaseReportsRepository {
  // Generate Sales Report
  Future<SalesReportModel> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Fetch aggregated data from monthlyAnalytics
    // Don't fetch all bills, use aggregated data
  }
  
  // Generate Purchase Report
  Future<PurchaseReportModel> generatePurchaseReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Fetch aggregated data from monthlyPurchases
  }
  
  // Generate Profit Report
  Future<ProfitReportModel> generateProfitReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Combine sales and purchase data
    // Calculate profit margins
  }
}
```

---

### **Phase 4: Reports UI** ⏳

#### 4.1 Reports Page
**File:** `lib/features/reports/presentation/page/reports_page.dart`

```
┌──────────────────────────────────────────────────┐
│ 📊 Reports                                       │
├──────────────────────────────────────────────────┤
│                                                  │
│ [Sales Report] [Purchase Report] [Profit Report]│
│                                                  │
│ Period: [This Month ▼]  [Generate Report]       │
│                                                  │
│ ┌────────────────────────────────────────────┐  │
│ │ Sales Report - December 2025               │  │
│ │                                            │  │
│ │ Total Revenue:      ₹1,25,000             │  │
│ │ Total Paid:         ₹1,00,000             │  │
│ │ Total Pending:      ₹25,000               │  │
│ │ Total Bills:        45                     │  │
│ │ Avg Bill Value:     ₹2,778                │  │
│ │ Collection Rate:    80%                    │  │
│ │                                            │  │
│ │ Top Selling Products:                      │  │
│ │ 1. Product A - 150 units                   │  │
│ │ 2. Product B - 120 units                   │  │
│ │                                            │  │
│ │ [Export PDF] [Export Excel]                │  │
│ └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

---

## 📊 **Firebase Collections Structure:**

```
analytics/
  └── 2025-12/
      ├── totalSales
      ├── totalPaid
      ├── totalPending
      ├── totalBills
      └── totalProductsSold

monthlyPurchases/
  └── 2025-12/
      ├── totalPurchaseAmount
      └── totalItemsPurchased

profitTracking/
  └── {productId}/
      ├── totalPurchaseCost
      ├── totalSalesRevenue
      ├── totalProfit
      └── unitsSold

stockLedger/
  └── {entryId}/
      ├── productId
      ├── type (sale/purchase)
      ├── qtyChange
      ├── finalStock
      └── referenceId
```

---

## ✅ **Benefits:**

1. **No Full Data Fetch** - Use aggregated monthly data
2. **Fast Reports** - Pre-calculated metrics
3. **Accurate Analytics** - Updated on every CRUD operation
4. **Audit Trail** - Stock ledger tracks everything
5. **Profit Tracking** - Real-time profit calculations

---

## 🚀 **Next Steps:**

Would you like me to:
1. **Implement Bill Edit/Delete** with analytics?
2. **Implement Purchase Analytics** updates?
3. **Create Report Models** and repository?
4. **Build Reports UI**?
5. **All of the above**?

Let me know and I'll start implementing! 🎊

