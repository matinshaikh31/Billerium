# Purchase Module Integration Guide

## Quick Start Guide to Integrate Purchase Module

### Step 1: Add BLoC Providers

Open `lib/app.dart` and add the purchase cubits to your MultiBlocProvider:

```dart
import 'package:billing_software/features/purchase/data/firebase_purchase_repository.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_cubit.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_form_cubit.dart';

// Inside MultiBlocProvider, add:
BlocProvider(
  create: (context) => PurchaseCubit(
    purchaseRepo: FirebasePurchaseRepository(),
  ),
),
BlocProvider(
  create: (context) => PurchaseFormCubit(
    purchaseRepo: FirebasePurchaseRepository(),
  ),
),
```

### Step 2: Add Navigation Route

If using GoRouter, add to your routes configuration:

```dart
import 'package:billing_software/features/purchase/presentation/page/purchase_list_page.dart';

GoRoute(
  path: '/purchases',
  name: 'purchases',
  builder: (context, state) => const PurchaseListPage(),
),
```

### Step 3: Add Menu/Navigation Item

Add a button or menu item in your dashboard/sidebar:

```dart
ListTile(
  leading: const Icon(Icons.shopping_bag),
  title: const Text('Purchases'),
  onTap: () {
    context.go('/purchases');
    // or Navigator.push(context, MaterialPageRoute(builder: (_) => PurchaseListPage()));
  },
),
```

### Step 4: Update Firestore Security Rules

Add these rules to your Firestore security rules:

```javascript
match /purchases/{purchaseId} {
  allow read, write: if request.auth != null;
}

match /stockLedger/{ledgerId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}

match /profitTracking/{productId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}

match /monthlyPurchases/{monthId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

### Step 5: Test the Flow

1. **Create a Purchase:**
   - Navigate to Purchases page
   - Click "New Purchase"
   - Add supplier info (optional)
   - Add items with quantity and purchase price
   - Submit

2. **Verify Updates:**
   - Check product stock increased
   - Check product's lastPurchasePrice updated
   - Check stockLedger collection has entry
   - Check profitTracking collection updated

3. **Create a Sale:**
   - Create a bill as usual
   - Verify stock decreased
   - Verify stockLedger has sale entry
   - Verify profitTracking updated with sales revenue

### Step 6: Create Analytics Dashboard (Optional)

Create a new page to display:

```dart
// Fetch profit data
final profitDocs = await FBFireStore.profitTracking.get();

// Display:
// - Total Purchase Cost
// - Total Sales Revenue
// - Total Profit
// - Profit Margin %
// - Top Profitable Products
```

### Step 7: Add to Existing Products Page (Optional)

Show purchase price info in product details:

```dart
if (product.lastPurchasePrice != null)
  Text('Last Purchase: ₹${product.lastPurchasePrice!.toStringAsFixed(2)}'),
if (product.averagePurchasePrice != null)
  Text('Avg Purchase: ₹${product.averagePurchasePrice!.toStringAsFixed(2)}'),

// Show profit margin
if (product.averagePurchasePrice != null) {
  final margin = ((product.price - product.averagePurchasePrice!) / product.price * 100);
  Text('Margin: ${margin.toStringAsFixed(1)}%');
}
```

---

## Firestore Collections Structure

### purchases
```json
{
  "purchaseNo": "PUR-1234567890",
  "supplierName": "ABC Suppliers",
  "supplierPhone": "9876543210",
  "items": [
    {
      "productId": "prod123",
      "productName": "Product A",
      "quantity": 10,
      "purchasePrice": 50.0,
      "total": 500.0
    }
  ],
  "subtotal": 500.0,
  "totalTax": 0.0,
  "finalAmount": 500.0,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### stockLedger
```json
{
  "productId": "prod123",
  "type": "purchase", // or "sale" or "return"
  "qtyChange": 10, // positive for purchase, negative for sale
  "finalStock": 110,
  "referenceId": "purchaseId or billId",
  "timestamp": "Timestamp"
}
```

### profitTracking
```json
{
  "totalPurchaseCost": 5000.0,
  "totalSalesRevenue": 7500.0,
  "totalProfit": 2500.0,
  "unitsSold": 100
}
```

### monthlyPurchases
```json
{
  "totalPurchaseAmount": 50000.0,
  "totalItemsPurchased": 500,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

---

## Testing Checklist

- [ ] Purchase creation works
- [ ] Product stock increases on purchase
- [ ] lastPurchasePrice updates correctly
- [ ] averagePurchasePrice calculates correctly
- [ ] Stock ledger entries created for purchases
- [ ] Stock ledger entries created for sales
- [ ] Profit tracking updates on purchase
- [ ] Profit tracking updates on sale
- [ ] Monthly purchase analytics updates
- [ ] Purchase list displays correctly
- [ ] Can view purchase details
- [ ] Can delete purchases (if needed)

---

## Common Issues & Solutions

### Issue: Products not showing in dropdown
**Solution:** Make sure ProductCubit is loaded and has fetched products before opening CreatePurchasePage.

### Issue: Stock not updating
**Solution:** Check Firebase permissions and ensure the product document exists.

### Issue: Average price calculation seems wrong
**Solution:** The formula is: `(currentAvg × currentStock + newPrice × newQty) / newStock`

### Issue: Profit showing negative
**Solution:** This is normal if you haven't made sales yet. Profit = Revenue - Cost.

---

## Future Enhancements

1. **Purchase Returns** - Add ability to return purchased items
2. **Supplier Management** - Create supplier master with history
3. **Purchase Orders** - Create PO before actual purchase
4. **Barcode Scanning** - Quick product selection
5. **Purchase Reports** - Detailed purchase analytics
6. **Low Stock Alerts** - Based on purchase patterns
7. **Reorder Levels** - Automatic purchase suggestions
8. **Multi-currency** - Support for foreign suppliers
9. **Purchase Approval** - Workflow for large purchases
10. **Vendor Comparison** - Compare prices across suppliers

---

## Support

For issues or questions:
1. Check PURCHASE_MODULE_IMPLEMENTATION.md for architecture details
2. Review the code in `lib/features/purchase/`
3. Check Firebase console for data structure
4. Verify all BLoC providers are registered

---

**Implementation Status:** ✅ Complete and Ready for Integration

