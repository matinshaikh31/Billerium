# Setup Instructions

## Prerequisites
- Flutter SDK 3.9.2 or higher
- Firebase account
- Android Studio / VS Code

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Configure Firebase

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase:
```bash
flutterfire configure
```

This will:
- Create a Firebase project (or select existing)
- Register your app with Firebase
- Generate `lib/firebase_options.dart` with your configuration

### Option B: Manual Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add your app (Web, Android, iOS)
4. Download configuration files
5. Update `lib/firebase_options.dart` with your credentials

## Step 3: Enable Firebase Services

In Firebase Console, enable:

1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"

2. **Cloud Firestore**
   - Go to Firestore Database
   - Create database in production mode
   - Set security rules (see below)

3. **Firebase Storage** (Optional - for product images)
   - Go to Storage
   - Get started

## Step 4: Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Require authentication for all operations
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 5: Create Admin User

1. Go to Firebase Console > Authentication > Users
2. Click "Add User"
3. Enter email and password
4. This will be your admin login

## Step 6: Run the App

### For Mobile (Android/iOS):
```bash
flutter run
```

### For Web:
```bash
flutter run -d chrome
```

### For Production Build:

**Android:**
```bash
flutter build apk --release
```

**Web:**
```bash
flutter build web --release
```

## Navigation Structure

The app uses **GoRouter** for navigation:

- `/` - Login Page (redirects to `/home` if authenticated)
- `/home` - Dashboard
- `/products` - Products Management
- `/categories` - Categories Management
- `/billing` - Create New Bill
- `/transactions` - Transaction History
- `/stock` - Stock Management

## Features Implemented

✅ Authentication (Admin Login/Logout)
✅ Dashboard with Statistics
✅ Category Management (CRUD)
✅ Product Management (CRUD)
✅ Billing System (Basic UI)
✅ Responsive Design (Mobile + Web)
✅ GoRouter Navigation
✅ Clean Architecture
✅ Cubit State Management

## Firestore Collections

### admins
```json
{
  "id": "auto-generated",
  "name": "Admin Name",
  "email": "admin@example.com",
  "createdAt": "Timestamp",
  "lastLogin": "Timestamp"
}
```

### categories
```json
{
  "id": "auto-generated",
  "name": "Electronics",
  "defaultDiscountPercent": 10.0,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### products
```json
{
  "id": "auto-generated",
  "name": "Laptop Dell XPS 15",
  "categoryId": "category-id",
  "price": 85000.0,
  "costPrice": 75000.0,
  "discountPercent": 10.0,
  "taxPercent": 18.0,
  "sku": "DELL-XPS-15",
  "imageUrl": "",
  "stockQty": 12,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### bills
```json
{
  "id": "auto-generated",
  "items": [
    {
      "productId": "product-id",
      "productName": "Laptop Dell XPS 15",
      "price": 85000.0,
      "quantity": 1,
      "discountPercent": 10.0,
      "taxPercent": 18.0
    }
  ],
  "customerName": "John Doe",
  "customerPhone": "9876543210",
  "subtotal": 85000.0,
  "totalDiscount": 8500.0,
  "totalTax": 13770.0,
  "billDiscountPercent": 0.0,
  "billDiscountAmount": 0.0,
  "finalAmount": 90270.0,
  "amountPaid": 90270.0,
  "pendingAmount": 0.0,
  "status": "Paid",
  "payments": [
    {
      "id": "payment-id",
      "amount": 90270.0,
      "mode": "Cash",
      "timestamp": "Timestamp"
    }
  ],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### transactions
```json
{
  "id": "auto-generated",
  "billId": "bill-id",
  "customerName": "John Doe",
  "amount": 90270.0,
  "mode": "Cash",
  "timestamp": "Timestamp"
}
```

### stockHistory
```json
{
  "id": "auto-generated",
  "productId": "product-id",
  "qtyChange": -1,
  "reason": "Billing",
  "date": "Timestamp"
}
```

## Troubleshooting

### Firebase not initialized
- Make sure you ran `flutterfire configure`
- Check that `lib/firebase_options.dart` exists
- Verify Firebase project settings

### Authentication errors
- Ensure Email/Password is enabled in Firebase Console
- Check that admin user exists in Authentication > Users

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter version: `flutter --version`

## Next Steps

To complete the full functionality:

1. Implement product form dialogs
2. Complete billing cart functionality
3. Add bill payment processing
4. Implement transactions page
5. Add stock management UI
6. Create analytics charts for dashboard
7. Add PDF invoice generation
8. Implement data export features

## Support

For issues, check:
- Flutter documentation: https://flutter.dev/docs
- Firebase documentation: https://firebase.google.com/docs
- GoRouter documentation: https://pub.dev/packages/go_router

