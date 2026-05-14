import 'package:flutter/material.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  List<Product> products = [];
  bool loading = false;
  String? error;

  Future<void> loadProducts() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      products = await _repository.getProducts();
    } catch (e) {
      error = 'No se pudieron cargar los productos';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(String barcode) async {
    try {
      await _repository.deleteProduct(barcode);
      products.removeWhere((product) => product.barcode == barcode);
      notifyListeners();
    } catch (e) {
      error = 'No se pudo eliminar el producto';
      notifyListeners();
    }
  }
}