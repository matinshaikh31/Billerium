import 'package:billing_software/features/products3/domain/entity/product_model.dart';

abstract class ProductRepository {
  Future<String> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<List<ProductModel>> searchProducts(String query);
}
