import 'package:flutter/material.dart';
import 'package:stikev/utils/widgets/custom_elevated_buttom.dart';
import 'package:stikev/utils/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.controller});
  final PageController controller;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //final LoginController _loginController = Get.put(LoginController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Image.asset(
                    "assets/images/vector-2.png",
                    width: constraints.maxWidth,
                    height: constraints.maxWidth * 1.07,
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color(0xFF755DC1),
                          fontSize: 27,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                      ),
                      const SizedBox(height: 17),
                      CustomTextField(
                        controller: _passController,
                        labelText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 25),
                      CustomElevatedButton(
                        onPressed: () {
                          widget.controller.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        buttonText: 'Create account',
                      ),
                      const SizedBox(height: 15),
                      _buildSignInRow(),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignInRow() {
    return Row(
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(
            color: Color(0xFF837E93),
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 2.5),
        InkWell(
          onTap: () {
            widget.controller.animateToPage(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          },
          child: const Text(
            'Log In',
            style: TextStyle(
              color: Color(0xFF755DC1),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
