import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getCurrentUser();
});