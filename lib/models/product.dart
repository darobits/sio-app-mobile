class Product {
  final String barcode;
  final String name;
  final int conversionFactor;
  final int currentStock;

  Product({
    required this.barcode,
    required this.name,
    required this.conversionFactor,
    required this.currentStock,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      conversionFactor: map['conversionFactor'] ?? 1,
      currentStock: map['currentStock'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'conversionFactor': conversionFactor,
      'currentStock': currentStock,
    };
  }
}