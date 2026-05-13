import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    final snapshot = await _db.collection('products').get();

    return snapshot.docs.map((doc) {
      return Product.fromMap(doc.data());
    }).toList();
  }

  Future<void> deleteProduct(String barcode) async {
    await _db.collection('products').doc(barcode).delete();
  }
}