import 'package:flutter/material.dart';
import 'package:pokedex_app/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthController _authController = AuthController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () async {
              await _authController.login(
                emailController as String,
                passwordController as String,
              );
            },

            child: Text("login"),
          ),
        ],
      ),
    );
  }
}
