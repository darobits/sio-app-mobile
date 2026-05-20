class OperationalStats {
  final int totalProducts;
  final int totalStock;
  final int totalReceptions;
  final int totalReceivedUnits;
  final int totalAudits;
  final int auditsWithDifference;
  final int lowStockProducts;

  final Map<String, int> receptionsByUser;
  final Map<String, int> receivedUnitsByProduct;
  final Map<String, int> receptionsByDay;
  final Map<String, int> auditsDifferenceByProduct;

  OperationalStats({
    required this.totalProducts,
    required this.totalStock,
    required this.totalReceptions,
    required this.totalReceivedUnits,
    required this.totalAudits,
    required this.auditsWithDifference,
    required this.lowStockProducts,
    required this.receptionsByUser,
    required this.receivedUnitsByProduct,
    required this.receptionsByDay,
    required this.auditsDifferenceByProduct,
  });
}