import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/managed_user.dart';

class UserManagementRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ManagedUser>> getUsers() async {
    final snapshot = await _db
        .collection('usuarios')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return ManagedUser.fromMap(
        id: doc.id,
        map: doc.data(),
      );
    }).toList();
  }

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    await _db.collection('usuarios').doc(uid).set(
      {
        'role': role,
        'rol': role,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}