import 'package:flutter/material.dart';

import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/recepcion_screen.dart';
import '../../screens/product_form_screen.dart';
import '../../screens/products_screen.dart';
import '../../screens/home_screen.dart';

class AppRouter {
  static const String login = "/";
  static const String register = "/register";
  static const String reception = "/recepcion";
  static const String productForm = "/productform";
  static const String products = "/products";
  static const String home = "/home";
  static const String statistics = "/statistics";
  static const String alerts = "/alerts";
  static const String profile = "/profile";

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

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
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

      case products:
        return MaterialPageRoute(
          builder: (_) => const ProductsScreen(),
        );

      case statistics:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            backgroundColor: Color(0xFF071827),
            body: Center(
              child: Text(
                "Estadísticas próximamente",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );

      case alerts:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            backgroundColor: Color(0xFF071827),
            body: Center(
              child: Text(
                "Alertas próximamente",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            backgroundColor: Color(0xFF071827),
            body: Center(
              child: Text(
                "Perfil próximamente",
                style: TextStyle(color: Colors.white),
              ),
            ),
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