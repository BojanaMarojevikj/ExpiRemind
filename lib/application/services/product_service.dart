import 'package:expiremind/data/repositories/product_repository.dart';

import '../../domain/models/product.dart';

class ProductService {
  final ProductRepository _productRepository = ProductRepository();

  Future<List<Product>> getProducts() async {
    return await _productRepository.fetchProducts();
  }

  Future<void> addProduct(Product product) async {
    await _productRepository.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _productRepository.updateProduct(product);
  }

  Future<void> deleteProduct(String productId) async {
    await _productRepository.deleteProduct(productId);
  }

}
