import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../repositories/audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository();
});

class AuditProductNotifier extends Notifier<Product?> {
  @override
  Product? build() {
    return null;
  }

  void setProduct(Product? product) {
    state = product;
  }

  void clear() {
    state = null;
  }
}

final auditProductProvider =
    NotifierProvider<AuditProductNotifier, Product?>(
  AuditProductNotifier.new,
);

class AuditLoadingNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setLoading(bool value) {
    state = value;
  }
}

final auditLoadingProvider =
    NotifierProvider<AuditLoadingNotifier, bool>(
  AuditLoadingNotifier.new,
);