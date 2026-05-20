import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';
import '../services/alert_service.dart';

class AuditRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Product?> getProductByBarcode(String barcode) async {
    final doc = await _db.collection('products').doc(barcode).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Product.fromMap(doc.data()!);
  }

  Future<void> saveAudit({
    required Product product,
    required int realStock,
  }) async {
    final user = _auth.currentUser;
    final expectedStock = product.currentStock;
    final difference = realStock - expectedStock;

    final batch = _db.batch();

    final auditRef = _db.collection('audits').doc();

    batch.set(auditRef, {
      'barcode': product.barcode,
      'productName': product.name,
      'expectedStock': expectedStock,
      'realStock': realStock,
      'difference': difference,
      'auditedByUid': user?.uid,
      'auditedByEmail': user?.email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final productRef = _db.collection('products').doc(product.barcode);

    batch.update(productRef, {
      'currentStock': realStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    await AlertService.checkAuditDifference(
      barcode: product.barcode,
      productName: product.name,
      expectedStock: expectedStock,
      realStock: realStock,
    );

    await AlertService.checkLowStock(
      barcode: product.barcode,
      productName: product.name,
      currentStock: realStock,
    );
  }
}