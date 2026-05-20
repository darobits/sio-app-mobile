import 'package:cloud_firestore/cloud_firestore.dart';

class SioAlert {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? barcode;
  final String? productName;
  final int? difference;
  final bool read;
  final DateTime? createdAt;

  SioAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.barcode,
    required this.productName,
    required this.difference,
    required this.read,
    required this.createdAt,
  });

  factory SioAlert.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    final timestamp = map['createdAt'];

    return SioAlert(
      id: id,
      type: map['type'] ?? 'general',
      title: map['title'] ?? 'Alerta',
      message: map['message'] ?? '',
      barcode: map['barcode'],
      productName: map['productName'],
      difference: map['difference'],
      read: map['read'] ?? false,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}