class ManagedUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  ManagedUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isOperator => role == 'operador';

  factory ManagedUser.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return ManagedUser(
      uid: map['uid'] ?? id,
      name: map['name'] ?? 'Sin nombre',
      email: map['email'] ?? 'Sin email',
      role: map['role'] ?? map['rol'] ?? 'operador',
      createdAt: map['createdAt']?.toDate(),
    );
  }
}