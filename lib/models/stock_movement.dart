class StockMovement {
  final String id;
  final String type;
  final String title;
  final String productName;
  final String barcode;
  final String userEmail;
  final int? quantity;
  final int? previousStock;
  final int? newStock;
  final int? expectedStock;
  final int? realStock;
  final int? difference;
  final DateTime? createdAt;

  StockMovement({
    required this.id,
    required this.type,
    required this.title,
    required this.productName,
    required this.barcode,
    required this.userEmail,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.expectedStock,
    required this.realStock,
    required this.difference,
    required this.createdAt,
  });
}