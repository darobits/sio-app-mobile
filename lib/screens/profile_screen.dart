import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../providers/user_provider.dart';
import '../widgets/sio_bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _roleLabel(String role) {
    if (role == 'admin') return 'Administrador';
    if (role == 'operador') return 'Operador';
    return role;
  }

  void _showModernSnack(
    BuildContext context, {
    required String message,
    required bool success,
  }) {
    if (!context.mounted) return;

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

  Future<void> _editName(
    BuildContext parentContext,
    WidgetRef ref,
    String currentName,
  ) async {
    final nameCtrl = TextEditingController(text: currentName);

    final result = await showModalBottomSheet<bool>(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        bool saving = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bottomSheetHandle(),
                  const SizedBox(height: 22),
                  const Text(
                    'Editar nombre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este cambio se actualiza directamente en tu perfil.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameCtrl,
                    enabled: !saving,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nombre y apellido',
                      prefixIcon: const Icon(Icons.person_rounded),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              final newName = nameCtrl.text.trim();
                              final authUser =
                                  FirebaseAuth.instance.currentUser;

                              if (newName.isEmpty) {
                                setModalState(() {
                                  errorMessage = 'Ingresá un nombre válido';
                                });
                                return;
                              }

                              if (authUser == null) {
                                setModalState(() {
                                  errorMessage = 'No hay usuario autenticado';
                                });
                                return;
                              }

                              try {
                                setModalState(() {
                                  saving = true;
                                  errorMessage = null;
                                });

                                await authUser.updateDisplayName(newName);

                                await FirebaseFirestore.instance
                                    .collection('usuarios')
                                    .doc(authUser.uid)
                                    .update({
                                  'name': newName,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                });

                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop(true);
                                }
                              } catch (_) {
                                setModalState(() {
                                  saving = false;
                                  errorMessage =
                                      'No se pudo actualizar el nombre';
                                });
                              }
                            },
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(saving ? 'Guardando...' : 'Guardar nombre'),
                      style: _primaryButtonStyle(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    nameCtrl.dispose();

    if (result == true) {
      await Future.delayed(const Duration(milliseconds: 300));

      ref.invalidate(currentUserProvider);

      if (parentContext.mounted) {
        _showModernSnack(
          parentContext,
          message: 'Nombre actualizado correctamente',
          success: true,
        );
      }
    }
  }

  Future<void> _editEmail(
    BuildContext parentContext,
    String currentEmail,
  ) async {
    final emailCtrl = TextEditingController(text: currentEmail);

    final result = await showModalBottomSheet<String>(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        bool sending = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bottomSheetHandle(),
                  const SizedBox(height: 22),
                  const Text(
                    'Cambiar email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Se enviará un link al nuevo correo. El cambio se aplica recién cuando lo verifiques.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, height: 1.35),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: emailCtrl,
                    enabled: !sending,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nuevo email',
                      prefixIcon: const Icon(Icons.email_rounded),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: sending
                          ? null
                          : () async {
                              final newEmail = emailCtrl.text.trim();
                              final authUser =
                                  FirebaseAuth.instance.currentUser;

                              if (newEmail.isEmpty ||
                                  !newEmail.contains('@') ||
                                  !newEmail.contains('.')) {
                                setModalState(() {
                                  errorMessage = 'Ingresá un email válido';
                                });
                                return;
                              }

                              if (newEmail == currentEmail) {
                                setModalState(() {
                                  errorMessage =
                                      'El email ingresado es el mismo actual';
                                });
                                return;
                              }

                              if (authUser == null) {
                                setModalState(() {
                                  errorMessage = 'No hay usuario autenticado';
                                });
                                return;
                              }

                              try {
                                setModalState(() {
                                  sending = true;
                                  errorMessage = null;
                                });

                                await authUser.verifyBeforeUpdateEmail(
                                  newEmail,
                                );

                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop('success');
                                }
                              } on FirebaseAuthException catch (e) {
                                setModalState(() {
                                  sending = false;
                                  errorMessage =
                                      e.code == 'requires-recent-login'
                                          ? 'Por seguridad, cerrá sesión y volvé a ingresar para cambiar el email'
                                          : 'No se pudo solicitar el cambio de email';
                                });
                              } catch (_) {
                                setModalState(() {
                                  sending = false;
                                  errorMessage =
                                      'No se pudo solicitar el cambio de email';
                                });
                              }
                            },
                      icon: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.mark_email_read_rounded),
                      label: Text(
                        sending ? 'Enviando...' : 'Enviar verificación',
                      ),
                      style: _primaryButtonStyle(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    emailCtrl.dispose();

    if (result == 'success') {
      await Future.delayed(const Duration(milliseconds: 300));

      if (parentContext.mounted) {
        _showModernSnack(
          parentContext,
          message: 'Te enviamos un link para verificar el nuevo email',
          success: true,
        );
      }
    }
  }

  Future<void> _sendPasswordReset(
    BuildContext context,
    String email,
  ) async {
    if (email.isEmpty || email == 'Sin email') {
      _showModernSnack(
        context,
        message: 'No hay email válido para enviar recuperación',
        success: false,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (context.mounted) {
        _showModernSnack(
          context,
          message: 'Cambio de contraseña enviado correctamente',
          success: true,
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showModernSnack(
          context,
          message: 'No se pudo enviar el email de recuperación',
          success: false,
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.login,
        (_) => false,
      );
    }
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF16A085),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _bottomSheetHandle() {
    return Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _logout(context),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.redAccent.withOpacity(0.42)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final firebaseEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Perfil'),
      ),
      bottomNavigationBar: const SioBottomNav(
        currentRoute: AppRouter.profile,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text(
            'No se pudo cargar el perfil',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        data: (user) {
          final name = user?.name.trim().isNotEmpty == true
              ? user!.name
              : 'Sin nombre';

          final email = firebaseEmail?.trim().isNotEmpty == true
              ? firebaseEmail!
              : user?.email ?? 'Sin email';

          final role = _roleLabel(user?.role ?? 'operador');

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
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
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A085).withOpacity(0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF16A085).withOpacity(0.45),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Color(0xFF16A085),
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Información de cuenta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _infoCard(
                icon: Icons.person_rounded,
                label: 'Nombre',
                value: name,
                color: const Color(0xFF16A085),
              ),
              _infoCard(
                icon: Icons.email_rounded,
                label: 'Email',
                value: email,
                color: const Color(0xFF4F7BFF),
              ),
              _infoCard(
                icon: Icons.verified_user_rounded,
                label: 'Rol',
                value: role,
                color: const Color(0xFFFFC857),
              ),
              const SizedBox(height: 18),
              const Text(
                'Acciones rápidas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _actionCard(
                icon: Icons.person_rounded,
                title: 'Editar nombre',
                subtitle: 'Actualizar el nombre visible del perfil.',
                color: const Color(0xFF16A085),
                onTap: () => _editName(context, ref, name),
              ),
              _actionCard(
                icon: Icons.email_rounded,
                title: 'Cambiar email',
                subtitle: 'Solicitar cambio mediante verificación por correo.',
                color: const Color(0xFF4F7BFF),
                onTap: () => _editEmail(context, email),
              ),
              _actionCard(
                icon: Icons.lock_reset_rounded,
                title: 'Cambiar contraseña',
                subtitle: 'Enviar link seguro de recuperación al email.',
                color: const Color(0xFFFFC857),
                onTap: () => _sendPasswordReset(context, email),
              ),
              _actionCard(
                icon: Icons.notifications_active_rounded,
                title: 'Configurar alertas',
                subtitle: 'Elegí qué eventos deben avisarte en el celular.',
                color: const Color(0xFFFF5C70),
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.alerts);
                },
              ),
              _actionCard(
                icon: Icons.bar_chart_rounded,
                title: 'Ver estadísticas',
                subtitle: 'Consultá indicadores y movimientos operativos.',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.statistics);
                },
              ),
              const SizedBox(height: 12),
              _logoutButton(context),
            ],
          );
        },
      ),
    );
  }
}