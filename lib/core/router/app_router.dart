import 'package:flutter/material.dart';

import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/recepcion_screen.dart';
import '../../screens/product_form_screen.dart';

class AppRouter {
  static const String login = "/";
  static const String register = "/register";
  static const String reception = "/recepcion";
  static const String productForm = "/productform";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case reception:
        return MaterialPageRoute(
          builder: (_) => const RecepcionScreen(),
        );

      case productForm:
        final barcode = settings.arguments;

        if (barcode is! String || barcode.trim().isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              backgroundColor: Color(0xFF071827),
              body: Center(
                child: Text(
                  "No se recibió un código de barras válido",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => ProductFormScreen(
            barcode: barcode.trim(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            backgroundColor: Color(0xFF071827),
            body: Center(
              child: Text(
                "Ruta no encontrada",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
    }
  }
}