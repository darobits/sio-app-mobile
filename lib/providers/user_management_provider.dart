import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/managed_user.dart';
import '../repositories/user_management_repository.dart';

final userManagementRepositoryProvider =
    Provider<UserManagementRepository>((ref) {
  return UserManagementRepository();
});

final userManagementProvider = FutureProvider<List<ManagedUser>>((ref) async {
  final repository = ref.read(userManagementRepositoryProvider);
  return repository.getUsers();
});