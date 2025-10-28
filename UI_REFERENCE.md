# UI Reference Guide

Based on the reference images provided, here's the UI implementation guide for each page.

## Color Scheme

- **Primary Color**: `#2563EB` (Blue)
- **Background**: White/Light Gray
- **Text**: Dark Gray/Black
- **Success**: Green
- **Warning**: Orange
- **Error**: Red

## 1. Products Page

### Layout
- **Header**: "Products" title with "Add Product" button (desktop) or FAB (mobile)
- **Search Bar**: Search by name or SKU
- **Filter**: "All Categories" dropdown
- **Table/List**: Product list with columns:
  - Product name
  - Category
  - SKU
  - Price
  - Discount
  - Final Price
  - Stock (with low stock indicator)
  - Actions (Edit, Delete)

### Features
- Low stock items show orange warning badge
- Responsive table → list on mobile
- Click product to edit
- Delete confirmation dialog

### Implementation Status
✅ Basic page structure created
⏳ Product form dialog (TODO)
⏳ Search functionality (TODO)
⏳ Category filter (TODO)

## 2. Categories Page

### Layout
- **Header**: "Categories" title with "Add Category" button
- **Grid/List**: Category cards showing:
  - Category icon
  - Category name
  - Product count (e.g., "45 products")
  - Default discount percentage (e.g., "10%")
  - Edit and Delete icons

### Features
- Grid layout on desktop (3-4 columns)
- List layout on mobile
- Color-coded category icons
- Hover effects on cards

### Implementation Status
✅ Fully implemented
✅ CRUD operations working
✅ Responsive design

## 3. Create Bill Page

### Layout

**Left Section (Product Search & Cart):**
- Search bar at top
- Cart items list showing:
  - Product name
  - Quantity controls (-, +)
  - Price per unit
  - Total price
  - Remove button

**Right Section (Bill Summary):**
- Subtotal
- Discount
- Grand Total (large, bold)
- "Proceed to Payment" button

**Bottom Section (Customer Details - Optional):**
- Customer Name field
- Phone Number field

**Bill Discount Section:**
- Discount type selector (Percentage/Amount)
- Discount value input

**Payment Details:**
- Amount Received input
- Payment Mode dropdown (Cash, UPI, Card, Other)
- Payment Status indicator
- "Save & Print Invoice" button

### Features
- Real-time cart updates
- Auto-calculation of totals
- Product search with autocomplete
- Barcode scanning support
- Multiple payment modes
- Partial payment support

### Implementation Status
✅ Basic page structure created
⏳ Product search (TODO)
⏳ Cart management (TODO)
⏳ Payment processing (TODO)
⏳ Invoice generation (TODO)

## 4. Stock & Inventory Page

### Layout

**Header:**
- "Stock & Inventory" title
- "Stock History" button
- "Add Stock" button

**Table:**
- Product name
- SKU
- Current Stock
- Min Stock threshold
- Status badge (Good Stock/Low Stock)
- Last Updated date

### Features
- Color-coded status:
  - Green: Good Stock
  - Red: Low Stock
- Filter by status
- Stock adjustment dialog
- Stock history modal

### Implementation Status
✅ Basic models created
⏳ Stock page UI (TODO)
⏳ Stock adjustment (TODO)
⏳ Stock history (TODO)

## 5. Dashboard Page

### Layout

**Top Stats Cards (4 columns):**
1. Today's Sales
   - Amount: ₹12,450
   - Change: +12.5% from yesterday
   - Icon: Dollar sign

2. Total Products
   - Count: 247
   - Subtitle: Across 18 categories
   - Icon: Box

3. Categories
   - Count: 18
   - Subtitle: Active categories
   - Icon: Grid

4. Monthly Revenue
   - Amount: ₹67,000
   - Change: +4.2% from last month
   - Icon: Trending up

**Bill Status Cards (3 columns):**
1. Paid Bills
   - Count: 156
   - Subtitle: This month
   - Color: Green

2. Partially Paid
   - Count: 23
   - Amount: Pending ₹45,230
   - Color: Orange

3. Unpaid Bills
   - Count: 8
   - Amount: Total ₹18,900
   - Color: Red

**Charts Section (2 columns):**
1. Monthly Sales Chart
   - Bar chart showing last 6 months
   - Y-axis: Sales amount
   - X-axis: Months

2. Top Selling Products
   - List of top 5 products
   - Product name
   - Units sold
   - Revenue

### Features
- Real-time data updates
- Interactive charts
- Quick action buttons
- Responsive grid layout

### Implementation Status
✅ Basic page structure created
⏳ Real data integration (TODO)
⏳ Charts implementation (TODO)
⏳ Top products list (TODO)

## 6. Sidebar Navigation (Desktop)

### Layout
- **Header Section**:
  - App logo/icon
  - App name: "BillManager"
  - Subtitle: "Inventory & POS"
  - Admin email

- **Menu Items**:
  - Dashboard (home icon)
  - Create Bill (receipt icon)
  - Bills (list icon)
  - Products (inventory icon)
  - Categories (category icon)
  - Transactions (payment icon)
  - Stock (warehouse icon)

- **Footer**:
  - Logout button (red)

### Features
- Active route highlighting
- Icons with labels
- Hover effects
- Fixed width: 250px

### Implementation Status
✅ Fully implemented
✅ GoRouter integration
✅ Active route detection

## 7. Mobile Navigation

### Layout
- **Drawer** (same as desktop sidebar)
- **Bottom Navigation** (alternative):
  - Home
  - Products
  - Bills
  - More

### Implementation Status
✅ Drawer implemented
⏳ Bottom navigation (TODO)

## Common UI Patterns

### Cards
```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: // Content
  ),
)
```

### Buttons
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: () {},
  child: Text('Button Text'),
)
```

### Input Fields
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    prefixIcon: Icon(Icons.search),
  ),
)
```

### Status Badges
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.green.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Good Stock',
    style: TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

## Responsive Breakpoints

```dart
// Mobile: < 600px
if (MediaQuery.of(context).size.width < 600) {
  // Mobile layout
}

// Tablet: 600px - 900px
else if (MediaQuery.of(context).size.width < 900) {
  // Tablet layout
}

// Desktop: > 900px
else {
  // Desktop layout
}
```

## Icons Used

- Dashboard: `Icons.dashboard`
- Products: `Icons.inventory_2`
- Categories: `Icons.category`
- Bills: `Icons.receipt` / `Icons.list_alt`
- Create Bill: `Icons.receipt_long`
- Transactions: `Icons.payment`
- Stock: `Icons.warehouse`
- Search: `Icons.search`
- Add: `Icons.add`
- Edit: `Icons.edit`
- Delete: `Icons.delete`
- Logout: `Icons.logout`

## Typography

```dart
// Page Title
TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
)

// Section Title
TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
)

// Body Text
TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
)

// Caption
TextStyle(
  fontSize: 12,
  color: Colors.grey,
)
```

## Spacing

- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **XLarge**: 32px

## Next Steps for UI Completion

1. ✅ Implement product form dialog
2. ✅ Complete billing cart functionality
3. ✅ Add charts to dashboard
4. ✅ Create transactions page
5. ✅ Implement stock management UI
6. ✅ Add data tables with sorting/filtering
7. ✅ Implement search functionality
8. ✅ Add loading states and error handling
9. ✅ Create invoice preview/print
10. ✅ Add animations and transitions

