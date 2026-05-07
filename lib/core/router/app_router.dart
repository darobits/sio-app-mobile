import 'package:flutter/material.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/recepcion_screen.dart';

class AppRouter {

  static const String login = "/";
  static const String register = "/register";
  static const String reception = "/recepcion";

  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case reception:
        return MaterialPageRoute(builder: (_) => const RecepcionScreen());  
        

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Ruta no encontrada")),
          ),
        );
    }
  }
}