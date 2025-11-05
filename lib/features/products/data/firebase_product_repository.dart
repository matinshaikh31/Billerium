import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/products/domain/repositories/product_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseProductRepository extends ProductRepository {
  final productsCollectionRef = FBFireStore.products;

  @override
  Future<String> createProduct(ProductModel product) async {
    try {
      final docRef = productsCollectionRef.doc();
      final now = Timestamp.now();

      final newProduct = ProductModel(
        id: docRef.id,
        name: product.name,
        categoryId: product.categoryId,
        price: product.price,
        discountPercent: product.discountPercent,
        sku: product.sku,
        stockQty: product.stockQty,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(newProduct.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        categoryId: product.categoryId,
        price: product.price,
        discountPercent: product.discountPercent,
        sku: product.sku,
        stockQty: product.stockQty,
        createdAt: product.createdAt,
        updatedAt: Timestamp.now(),
      );

      await productsCollectionRef
          .doc(product.id)
          .update(updatedProduct.toJson());
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await productsCollectionRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await productsCollectionRef
          .orderBy('name')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .get();

      return snapshot.docs.map((doc) => ProductModel.fromDocSnap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }
}
