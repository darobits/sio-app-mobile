import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final productProvider =
    AsyncNotifierProvider<ProductNotifier, List<Product>>(
  ProductNotifier.new,
);

class ProductNotifier extends AsyncNotifier<List<Product>> {
  late final ProductRepository _repository;

  @override
  Future<List<Product>> build() async {
    _repository = ref.read(productRepositoryProvider);
    return _repository.getProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _repository.getProducts();
    });
  }

  Future<void> deleteProduct(String barcode) async {
    await _repository.deleteProduct(barcode);

    state = await AsyncValue.guard(() async {
      return _repository.getProducts();
    });
  }
}