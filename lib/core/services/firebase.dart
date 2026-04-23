// import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FBAuth {
  static final auth = FirebaseAuth.instance;
}

class FBFireStore {
  static final fb = FirebaseFirestore.instance;
  static final products = fb.collection('products');
  static final categories = fb.collection('categories');
  static final bills = fb.collection('bills');
  static final transactions = fb.collection('transactions');
  static final settings = fb.collection('settings').doc("sets");
  static final analytics = fb.collection("analytics");
  static final purchases = fb.collection('purchases');
  static final stockLedger = fb.collection('stockLedger');
  static final profitTracking = fb.collection('profitTracking');
  static final monthlyPurchases = fb.collection('monthlyPurchases');
  static final customers = fb.collection('customers');
  static final setting = fb.collection('settings').doc("sets");
}

class FBStorage {
  static final fbstore = FirebaseStorage.instance;
  static final products = fbstore.ref().child('products');
  static final banners = fbstore.ref().child('banners');
  static final category = fbstore.ref().child('category');
}

// class FBFunctions {
//   static final ff = FirebaseFunctions.instance;
// }
