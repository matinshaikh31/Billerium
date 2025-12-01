Great — you shared all your models, and now you want to add a **Purchase Module** + improve analytics + track stock + profitability.
Below is **a complete architecture**, **models you need to add**, **changes required**, and **extra features you can offer to the client**.

---

# ✅ **What Your Client Wants**

You currently have:

* Product
* Bill (sales)
* Stock deduction on sale
* Analytics + Monthly analytics

But now client wants:

### ✔ Purchase Module (Purchase Inwards)

* Record product purchase from suppliers
* Track per-product purchase price
* Track stock added from purchase
* Track total purchase amount
* Track profit (sell price − purchase price)
* Know purchase history
* Know cost of goods

---

# ✅ **Why It Cannot Work With Your Current Models**

Your **ProductModel** only stores:

* selling price
* stockQty

You do **not** store:

* purchase price
* purchase history
* supplier details
* per product purchase totals

This is why you **must introduce a Purchase system**.

---

# ✅ **New Models You Need (IMPORTANT)**

---

# 1️⃣ **Purchase Model**

Used when store buys stock.

```dart
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
```

---

# 2️⃣ **Purchase Item Model**

Every item that is purchased.

```dart
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
```

---

# 3️⃣ **Stock Ledger (Highly Recommended)**

To track all stock movements.

```dart
class StockLedgerModel {
  final String id;
  final String productId;
  final String type; // "purchase", "sale", "return"
  final int qtyChange;
  final int finalStock;
  final String referenceId; // billId or purchaseId
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
```

---

# 4️⃣ **Product Changes (IMPORTANT)**

Modify ProductModel to add:

```dart
final double? lastPurchasePrice;
final double? averagePurchasePrice;
```

Example:

```dart
class ProductModel {
  ...
  final double? lastPurchasePrice;
  final double? averagePurchasePrice;
}
```

---

# 5️⃣ **Profitability Model**

To store per-product profit.

```dart
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
```

---

# ✅ **How The Billing Flow Will Work After These Changes**

---

## 🔵 **When New Purchase Happens** (purchase-in)

For each purchase item:

1. Add quantity to product stock
2. Update product.lastPurchasePrice
3. Update product.averagePurchasePrice
4. Add entry into StockLedger
5. Update Purchase Analytics
6. Update Profit Model (purchase side)

---

## 🔴 **When Bill/Sale Happens**

For each BillItem:

1. Deduct stock
2. Add entry in StockLedger
3. Update Monthly Sales
4. Update Analytics
5. Update Profit Model (sales side)

---

# 📊 **New Monthly Analytics System**

Keep two separate documents:

### **1. MonthlySalesModel**

→ Tracks sales, bills, products sold etc.

### **2. MonthlyPurchaseModel**

→ Tracks purchase amount, purchase qty, suppliers etc.

Add this new model:

```dart
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
```

---