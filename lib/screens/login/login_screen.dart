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
  final ProfileController _profileController =
      Get.put(ProfileController()); // Instancia del controlador de perfil
  final RouteController _routeController = Get.put(RouteController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false; // Variable para manejar el estado de carga
  Future<void> fetchRoutesByCobrador() async {
    final cobradorId = 5; // Cambia esto al ID que necesitas
    final url = AppConfig.rutaCobradorApiUrl(cobradorId.toString());

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Bearer ${_loginController.token}', // Añade el token Bearer
      },
    );

    if (response.statusCode == 200) {
      var data =
          jsonDecode(response.body) as List; // Asegúrate de que es una lista
      // Cargar las rutas en el controlador
      List<Map<String, dynamic>> routes = data.map((item) {
        // Asegúrate de manejar posibles campos null
        return {
          'id': item['id'] ?? '', // Proporciona un valor predeterminado
          'nombre': item['nombre'] ?? '',
          'cobradorId': item['cobradorId'] ?? 0,
          'interes': item['interes'] ?? 0.0,
          'tMaximoPrestamo': item['tMaximoPrestamo'] ?? 0.0,
          'interesLibre': item['interesLibre'] ?? false,
          'fecha_creacion': item['fecha_creacion'] ?? '',
          'capitalId': item['capitalId'] ?? 0,
        };
      }).toList();
      _routeController.loadRoutes(routes);
    } else {
      // Manejo del error
      debugPrint("Error al obtener rutas: ${response.statusCode}");
    }
  }

  Future<void> fetchUserProfile() async {
    final url = AppConfig
        .profileApiUrl; // Asegúrate de definir esta URL en tu configuración
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Bearer ${_loginController.token}', // Añade el token Bearer
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      // Establecer los datos del perfil en el ProfileController
      _profileController.setProfileData(
        jsonResponse['user']['id'],
        jsonResponse['user']['email'],
        jsonResponse['user']['nombre'],
        jsonResponse['user']['telefono'],
        jsonResponse['user']['rolId'],
        jsonResponse['user']['estado'],
      );
      print("Perfil del usuario cargado: ${_profileController.email.value}");
    } else {
      // Manejo del error
      debugPrint("Error al obtener perfil: ${response.statusCode}");
    }
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

        // Ahora que tienes el token, realiza las peticiones para las rutas y el perfil
        await fetchRoutesByCobrador();
        await fetchUserProfile();
 
        // Navegar a la siguiente página
        widget.controller.animateToPage(
          1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.slowMiddle,
        );
      } else {
        
      
        // Acción en caso de fallo
        AlertHelper.showErrorAlert(context, 'Login failed. Please try again.');
      }
    } catch (e) {
      print("error login " + e.toString());
      // En caso de error en la solicitud
      AlertHelper.showErrorAlert(
          context, 'Error occurred. Please try again later.');
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
                      onChanged: (value) {
                        _loginController.setEmail(value);
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      onChanged: (value) {
                        _loginController.setPassword(value);
                      },
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
                        SizedBox(width: screenWidth * 0.02),
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
                    SizedBox(height: screenHeight * 0.01),
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
