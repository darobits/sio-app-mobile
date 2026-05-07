import 'package:flutter/material.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';

class AppRouter {

  static const String login = "/";
  static const String register = "/register";

  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Ruta no encontrada")),
          ),
        );
    }
  }
}