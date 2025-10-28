import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';
import '../dto/product_dto.dart';

class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;

  FirebaseProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _productsCollection =>
      _firestore.collection(AppConstants.productsCollection);

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _productsCollection.orderBy('name').get();

      return snapshot.docs
          .map((doc) => ProductDto.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ).toModel())
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final doc = await _productsCollection.doc(id).get();

      if (!doc.exists) {
        throw Exception('Product not found');
      }

      return ProductDto.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ).toModel();
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final snapshot = await _productsCollection
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => ProductDto.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ).toModel())
          .toList();
    } catch (e) {
      throw Exception('Failed to get products by category: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final lowerQuery = query.toLowerCase();

      // Search by name
      final nameSnapshot = await _productsCollection
          .orderBy('name')
          .startAt([lowerQuery])
          .endAt(['$lowerQuery\uf8ff'])
          .get();

      // Search by SKU
      final skuSnapshot = await _productsCollection
          .where('sku', isEqualTo: query)
          .get();

      final products = <ProductModel>[];
      final seenIds = <String>{};

      for (var doc in [...nameSnapshot.docs, ...skuSnapshot.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          products.add(ProductDto.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ).toModel());
        }
      }

      return products;
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }

  @override
  Future<String> createProduct(ProductModel product) async {
    try {
      final now = Timestamp.now();
      final dto = ProductDto(
        id: '',
        name: product.name,
        categoryId: product.categoryId,
        price: product.price,
        costPrice: product.costPrice,
        discountPercent: product.discountPercent,
        taxPercent: product.taxPercent,
        sku: product.sku,
        imageUrl: product.imageUrl,
        stockQty: product.stockQty,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _productsCollection.add(dto.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      final dto = ProductDto.fromModel(product);
      final data = dto.toJson();
      data['updatedAt'] = Timestamp.now();

      await _productsCollection.doc(product.id).update(data);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _productsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStock(String productId, int quantity) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (!doc.exists) {
        throw Exception('Product not found');
      }

      final currentStock = doc.data()!['stockQty'] as int;
      final newStock = currentStock + quantity;

      await _productsCollection.doc(productId).update({
        'stockQty': newStock,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update stock: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final snapshot = await _productsCollection
          .where('stockQty', isLessThan: 10)
          .orderBy('stockQty')
          .get();

      return snapshot.docs
          .map((doc) => ProductDto.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ).toModel())
          .toList();
    } catch (e) {
      throw Exception('Failed to get low stock products: ${e.toString()}');
    }
  }

  @override
  Stream<List<ProductModel>> watchProducts() {
    return _productsCollection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductDto.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ).toModel())
          .toList();
    });
  }
}

