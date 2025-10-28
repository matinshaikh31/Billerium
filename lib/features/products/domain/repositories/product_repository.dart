import '../models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<ProductModel>> searchProducts(String query);
  Future<String> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<void> updateStock(String productId, int quantity);
  Future<List<ProductModel>> getLowStockProducts();
  Stream<List<ProductModel>> watchProducts();
}

