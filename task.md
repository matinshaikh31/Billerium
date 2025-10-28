You are an expert Flutter, Firebase, and Clean Architecture developer.  
Generate a complete Billing & Inventory Management Software with Admin authentication, using Flutter, Firebase, and Cubit.  
It must support both Mobile and Web with responsive UI.

############################################################
#                    TECH STACK & RULES                   #
############################################################

Use the following tech stack:

- Flutter (Material 3 Design)
- Firebase:
  - Firebase Auth (Admin Login Only)
  - Firestore
  - Firebase Storage
- State Management: Cubit (not Bloc)
- Architecture: Clean Architecture + Feature-based
- Must support MOBILE + WEB responsive layouts

Responsive Rules:
- Use `LayoutBuilder`, `MediaQuery`, or a `ResponsiveWidget` class
- Mobile UI: Bottom navigation or Drawer
- Web UI: Sidebar navigation + wider layout

############################################################
#                 PROJECT FOLDER STRUCTURE                #
############################################################

lib/
  core/
    widgets/ (reusable widgets)
    utils/
    constants/
    responsive/ (helper for responsive UI)
  features/
    auth/
      presentation/ (cubit, pages, widgets)
      domain/ (models, repositories)
      data/ (firebase repo)
    products/
      presentation/ (cubit, pages, widgets)
      domain/ (models, repositories abstract)
      data/ (repositories + datasources)
    categories/
      ...
    billing/
      ...
    stock/
      ...
    transactions/
      ...
    dashboard/
      ...
  app.dart
  main.dart

Follow this structure for **every feature**.

############################################################
#                       AUTH MODULE                       #
############################################################

Only one role exists: **Admin**.

Features required:
- Admin Login with Email/Password
- Forgot Password (optional)
- Logout
- Store admin profile with:
  - id, name, email, createdAt, lastLogin

Auth Flow:
- If not logged in → show login page
- If logged in → go to dashboard

############################################################
#                 BILLING SOFTWARE FEATURES               #
############################################################

### 1. PRODUCT MODULE
- Add / Edit / Delete products
- Product Fields:
  id, name, categoryId, price, costPrice, discountPercent, taxPercent, sku/barcode,
  imageUrl, stockQty, createdAt, updatedAt
- Discount Logic:
  product discount overrides category discount
- On bill creation: stock reduces

Firestore: `products` collection

### 2. CATEGORY MODULE
Fields: id, name, defaultDiscountPercent
If product has no discount → apply category discount

Firestore: `categories` collection

### 3. BILLING / INVOICE MODULE
- Search products by name or barcode
- Add products with quantity
- Auto-calculation:
  - Subtotal
  - Best discount (product > category)
  - Optional manual bill discount (flat or %)
  - Tax
  - Grand Total
- Customer (optional): name, phone
- Bill Status: Paid, PartiallyPaid, Unpaid

Store bill with:
- billId, items[], totals, discounts, tax, finalAmount
- amountPaid, pendingAmount, status
- payments[] list with (amount, mode, timestamp)

Firestore: `bills` collection

### 4. PAYMENT & PARTIAL PAYMENTS
- On bill creation: enter payment + mode (Cash, UPI, Card, Other)
- If partial → status PartiallyPaid
- Add payment later
- Update due amount and status

Payment Entry:
paymentId, billId, amountReceived, mode, timestamp

### 5. STOCK MODULE
- Auto stock reduce on billing
- Increase on return (optional)
- Stock History:
  Fields: id, productId, qtyChange (+/-), reason, date

Firestore: `stockHistory` or subcollection under product

### 6. TRANSACTIONS MODULE
Store every payment in a global collection

Fields: id, billId, customerName, amount, mode, timestamp

Filters:
- Payment mode
- Date range

Firestore: `transactions` collection

### 7. DASHBOARD / ANALYTICS MODULE
Show:
- Total sales: daily, monthly, yearly
- Paid vs Partially vs Unpaid count
- Total products, total categories
- Low stock items
- Top 5 selling products
- Monthly sales graph
- Recent transactions (latest 10)

############################################################
#              FOR EACH FEATURE, GENERATE CODE            #
############################################################

For each module, generate:

1. Firestore Database Structure (with example documents)
2. Data Models (domain layer)
3. DTO with fromJson & toJson (data layer)
4. Abstract Repository (domain)
5. Firebase Repository Implementation (data)
6. Cubit (with states & logic)
7. UI (list, create/edit, details screens)
8. Responsive UI for mobile & web
9. Helper utilities (discount, tax, totals, payment logic)

Coding Requirements:
- Use Freezed or Equatable for models
- Write Cubit classes with proper clean states
- Use async/await & try/catch with failure handling
- Firestore queries must be optimized with indexes
- Use M3 design + reusable widgets

############################################################
#                       OUTPUT FORMAT                     #
############################################################

Provide output in the following order:

1. Firestore Collections + Example Data
2. Models & DTOs
3. Repositories (abstract + firebase)
4. Cubits
5. UI (Responsive)
6. Helpers
7. Navigation Flow
8. Any notes or TODO for future upgrades
