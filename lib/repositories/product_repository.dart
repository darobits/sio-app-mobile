import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    final snapshot = await _db.collection('products').get();

    final products = snapshot.docs.map((doc) {
      final data = doc.data();

      return Product(
        barcode: _asString(
          data['barcode'],
          fallback: doc.id,
        ),
        name: _asString(
          data['name'],
          fallback: 'Producto sin nombre',
        ),
        conversionFactor: _asInt(
          data['conversionFactor'],
          fallback: 1,
        ),
        currentStock: _asInt(
          data['currentStock'],
          fallback: 0,
        ),
      );
    }).toList();

    products.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return products;
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final doc = await _db.collection('products').doc(barcode).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;

    return Product(
      barcode: _asString(
        data['barcode'],
        fallback: doc.id,
      ),
      name: _asString(
        data['name'],
        fallback: 'Producto sin nombre',
      ),
      conversionFactor: _asInt(
        data['conversionFactor'],
        fallback: 1,
      ),
      currentStock: _asInt(
        data['currentStock'],
        fallback: 0,
      ),
    );
  }

  Future<void> deleteProduct(String barcode) async {
    await _db.collection('products').doc(barcode).delete();
  }

  int _asInt(
    dynamic value, {
    required int fallback,
  }) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;

    return fallback;
  }

  String _asString(
    dynamic value, {
    required String fallback,
  }) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return fallback;
  }
}