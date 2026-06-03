import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../models/managed_user.dart';
import '../providers/user_management_provider.dart';
import '../widgets/sio_bottom_nav.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<ManagedUser> _filterUsers(List<ManagedUser> users) {
    final query = searchCtrl.text.trim().toLowerCase();

    if (query.isEmpty) return users;

    return users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            success ? const Color(0xFF16A085) : Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    return role == 'admin'
        ? const Color(0xFFFFC857)
        : const Color(0xFF16A085);
  }

  String _roleLabel(String role) {
    if (role == 'admin') return 'Administrador';
    return 'Operador';
  }

  Widget _header(List<ManagedUser> users) {
    final admins = users.where((user) => user.role == 'admin').length;
    final operators = users.where((user) => user.role == 'operador').length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF16396E),
            Color(0xFF071827),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.manage_accounts_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(height: 16),
          const Text(
            'Gestión de usuarios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Administrá usuarios registrados, roles y permisos operativos del sistema.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _summaryCard(
                label: 'Usuarios',
                value: users.length.toString(),
                color: const Color(0xFF4F7BFF),
              ),
              const SizedBox(width: 8),
              _summaryCard(
                label: 'Admins',
                value: admins.toString(),
                color: const Color(0xFFFFC857),
              ),
              const SizedBox(width: 8),
              _summaryCard(
                label: 'Operadores',
                value: operators.toString(),
                color: const Color(0xFF16A085),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      controller: searchCtrl,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Buscar usuario, email o rol',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: searchCtrl.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  searchCtrl.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: const Color(0xFF111827),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _userCard(ManagedUser user) {
    final color = _roleColor(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: color.withOpacity(0.28)),
                  ),
                  child: Text(
                    _roleLabel(user.role),
                    style: TextStyle(
                      color: color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openRoleSelector(user),
            icon: const Icon(
              Icons.edit_rounded,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  void _openRoleSelector(ManagedUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                user.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 22),
              _roleOption(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Administrador',
                subtitle: 'Acceso completo al sistema',
                color: const Color(0xFFFFC857),
                selected: user.role == 'admin',
                onTap: () => _updateRole(user, 'admin'),
              ),
              const SizedBox(height: 12),
              _roleOption(
                icon: Icons.person_rounded,
                title: 'Operador',
                subtitle: 'Acceso operativo limitado',
                color: const Color(0xFF16A085),
                selected: user.role == 'operador',
                onTap: () => _updateRole(user, 'operador'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _roleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: selected ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : const Color(0xFF0B1B2B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color.withOpacity(0.45) : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A085),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRole(ManagedUser user, String role) async {
    Navigator.pop(context);

    try {
      final repository = ref.read(userManagementRepositoryProvider);

      await repository.updateUserRole(
        uid: user.uid,
        role: role,
      );

      ref.invalidate(userManagementProvider);

      _showSnack(
        'Rol actualizado correctamente',
        success: true,
      );
    } catch (_) {
      _showSnack(
        'No se pudo actualizar el rol',
        success: false,
      );
    }
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            color: Colors.white38,
            size: 50,
          ),
          SizedBox(height: 12),
          Text(
            'No hay usuarios para mostrar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cuando se registren usuarios, aparecerán en esta sección.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userManagementProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Gestión de usuarios'),
      ),
      bottomNavigationBar: const SioBottomNav(
        currentRoute: AppRouter.home,
      ),
      body: usersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => const Center(
          child: Text(
            'No se pudieron cargar los usuarios',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        data: (users) {
          final filteredUsers = _filterUsers(users);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userManagementProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _header(users),
                const SizedBox(height: 18),
                _searchBox(),
                const SizedBox(height: 18),
                if (filteredUsers.isEmpty)
                  _emptyState()
                else
                  ...filteredUsers.map(_userCard),
              ],
            ),
          );
        },
      ),
    );
  }
}