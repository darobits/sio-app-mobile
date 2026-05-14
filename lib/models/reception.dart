import 'package:cloud_firestore/cloud_firestore.dart';

class Reception {
  final String id;
  final String barcode;
  final String productName;
  final int conversionFactor;
  final int receivedQuantity;
  final int totalUnits;
  final String receivedByEmail;
  final String receivedByUid;
  final DateTime? createdAt;

  Reception({
    required this.id,
    required this.barcode,
    required this.productName,
    required this.conversionFactor,
    required this.receivedQuantity,
    required this.totalUnits,
    required this.receivedByEmail,
    required this.receivedByUid,
    required this.createdAt,
  });

  factory Reception.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    final timestamp = map['createdAt'];

    return Reception(
      id: id,
      barcode: map['barcode'] ?? '',
      productName: map['productName'] ?? '',
      conversionFactor: map['conversionFactor'] ?? 1,
      receivedQuantity: map['receivedQuantity'] ?? 0,
      totalUnits: map['totalUnits'] ?? 0,
      receivedByEmail: map['receivedByEmail'] ?? 'Sin usuario',
      receivedByUid: map['receivedByUid'] ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}