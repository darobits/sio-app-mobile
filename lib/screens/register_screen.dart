import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();

  bool loading = false;

  Future<void> register() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    List<String> errores = [];

    if (name.isEmpty) {
      errores.add("• El nombre es obligatorio");
    }

    if (email.isEmpty) {
      errores.add("• El email es obligatorio");
    } else if (!email.contains("@") || !email.contains(".")) {
      errores.add("• Email inválido");
    }

    if (password.isEmpty) {
      errores.add("• La contraseña es obligatoria");
    } else if (password.length < 6) {
      errores.add("• Mínimo 6 caracteres");
    }

    if (errores.isNotEmpty) {
      showModernDialog("Error", errores.join("\n"), false);
      return;
    }

    setState(() => loading = true);

    try {
      final res = await auth.register(name, email, password);

      setState(() => loading = false);

      if (res == null) {
        showModernDialog(
          "Cuenta creada",
          "Revisá tu email para verificar tu cuenta",
          true,
        );
      } else {
        handleFirebaseError(res);
      }
    } catch (e) {
      setState(() => loading = false);
      showModernDialog("Error", "Error inesperado", false);
    }
  }

  void handleFirebaseError(String error) {
    List<String> errores = [];

    if (error.contains("email-already-in-use")) {
      errores.add("• Este email ya está registrado");
    }

    if (error.contains("invalid-email")) {
      errores.add("• El formato del email no es válido");
    }

    if (error.contains("weak-password")) {
      errores.add("• La contraseña es demasiado débil");
    }

    if (errores.isEmpty) {
      errores.add("• Error al registrarse");
    }

    showModernDialog("Error", errores.join("\n"), false);
  }

  void goToLogin() {
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  void showModernDialog(String title, String message, bool success) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF121E2D),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(0, 15),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: success
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(14),
                child: Icon(
                  success ? Icons.check_rounded : Icons.close_rounded,
                  size: 40,
                  color: success ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);

                  if (success) {
                    goToLogin();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 30,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 22, 57, 110),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget inputTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1B1F3A),
                  Color(0xFF3A2B6A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: Image.asset(
                          'assets/logo.jpeg',
                          height: 250,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Crear cuenta",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          inputTitle("Nombre y apellido"),
                          TextField(
                            controller: nameCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ej: Darío Villar',
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.25),
                              hintStyle:
                                  const TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          inputTitle("Email"),
                          TextField(
                            controller: emailCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ej: usuario@gmail.com',
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.25),
                              hintStyle:
                                  const TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          inputTitle("Contraseña"),
                          TextField(
                            controller: passCtrl,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Mínimo 6 caracteres',
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.25),
                              hintStyle:
                                  const TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading ? null : register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5E3EC8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text("Crear cuenta"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: goToLogin,
                      child: const Text(
                        "Ya tengo cuenta",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: goToLogin,
            ),
          ),
        ],
      ),
    );
  }
}