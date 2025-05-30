import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/session_manager.dart';
import 'home_screen.dart';

class RegisterScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: "Contraseña"),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () async {
              final user = await authService.register(emailController.text, passwordController.text);
              if (user != null) {
                await SessionManager.saveEmail(user.email ?? '');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al registrar')));
              }
            },
            child: Text("Registrarse"),
          ),
        ]),
      ),
    );
  }
}
