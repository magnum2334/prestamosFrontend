// Pantalla de inicio de sesión
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stikev/getX/LoginController.dart';
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

  @override
  void initState() {
    super.initState();
    _emailController.text = _loginController.email.value;
    _passwordController.text = _loginController.password.value;

    _emailController.addListener(() {
      _loginController.setEmail(_emailController.text);
    });

    _passwordController.addListener(() {
      _loginController.setPassword(_passwordController.text);
    });
  }

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

    try {
      var response = await http.post(
        Uri.parse(AppConfig.authApiUrl),
        body: {
          'email': email,
          'password': password,
        },
      );
      // Imprimir el código de estado y cuerpo de la respuesta
      // print('Status code: ${response.statusCode}');
      // print('Response body: ${response.body}');
      // print('authApiUrl: ${AppConfig.authApiUrl}');
      if (response.statusCode == 201) {
        // Acción en caso de éxito
        // ignore: use_build_context_synchronously
        AlertHelper.showSuccessAlert(context, 'Login successful');
      } else {
        // Acción en caso de fallo
        AlertHelper.showErrorAlert(context, 'Login failed. Please try again.');
      }
    } catch (e) {
      // En caso de error en la solicitud
      AlertHelper.showErrorAlert(
          context, 'Error occurred. Please try again later.');
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
                      onChanged: (value) {
                        _loginController.setEmail(value);
                      },
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      onChanged: (value) {
                        _loginController.setPassword(value);
                      },
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    CustomElevatedButton(
                      onPressed: _login,
                      buttonText: 'Sign In',
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Row(
                      children: [
                        Text(
                          'Don’t have an account?',
                          style: TextStyle(
                            color: Color(0xFF837E93),
                            fontSize: screenWidth * 0.04,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        InkWell(
                          onTap: () {
                            widget.controller.animateToPage(1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppStyles.text,
                              fontSize: screenWidth * 0.04,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Text(
                      'Forget Password?',
                      style: TextStyle(
                        color: AppStyles.text,
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
