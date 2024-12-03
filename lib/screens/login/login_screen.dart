import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/getX/ProfileController.dart'; // Importa el controlador de perfil
import 'package:stikev/getX/RouteController.dart';
import 'package:stikev/utils/Alert_helper.dart';
import 'package:stikev/utils/main_style.dart';
import 'package:stikev/utils/route_config.dart';
import 'package:stikev/utils/widgets/custom_elevated_buttom.dart';
import 'package:stikev/utils/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});
  final PageController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _loginController = Get.put(LoginController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ProfileController _profileController = Get.put(ProfileController());
  final RouteController _routeController = Get.put(RouteController());
  bool isLoading = false; // Variable para manejar el estado de carga

  Future<void> _login() async {
    String email = _loginController.email.value;
    String password = _loginController.password.value;

    if (email.isEmpty || password.isEmpty) {
      AlertHelper.showErrorAlert(
        context,
        'Por favor, completa ambos campos de correo electrónico y contraseña.',
      );
      return;
    }

    setState(() {
      isLoading = true; // Inicia el estado de carga
    });

    try {
      // Solicitud de login
      final response = await http.post(
        Uri.parse(AppConfig.authApiUrl),
        body: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        String accessToken = jsonResponse['accessToken'];
        _loginController.setToken(accessToken); // Guarda el token
        // Navegar a la siguiente página
        final profile = await _profileController
          .fetchUserProfile(_loginController.token.toString());
        await _routeController.fetchRoutesByCobrador(
          _loginController.token.toString(), profile['user']['id']);

        widget.controller.animateToPage(
          1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.slowMiddle,
        );
      } else {
        // Acción en caso de fallo
        AlertHelper.showErrorAlert(context, ' ${response.statusCode}');
      }
    } catch (e) {
      print("error login " + e.toString());
      // En caso de error en la solicitud
      AlertHelper.showErrorAlert(
          context, 'Error . ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false; // Finaliza el estado de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.01),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  "assets/images/vector-1.png",
                  width: screenWidth * 1.5,
                  height: screenHeight * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      onChanged: (value) {
                        _loginController.setEmail(value);
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: const Icon(Icons.password_sharp),
                      height: 70,
                      onChanged: (value) {
                        _loginController.setPassword(value);
                      }, // Aumentar altura
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Mostrar el botón o el spinner
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomElevatedButton(
                            onPressed: _login,
                            buttonText: 'Sign In',
                          ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
