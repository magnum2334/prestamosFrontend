import 'package:flutter/material.dart';
import 'package:stikev/screens/dasboard/bottom_navbar.dart';
import 'package:stikev/screens/login/login_screen.dart';
import 'package:stikev/screens/verify_screen.dart';
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        controller: controller,
        itemBuilder: (context, index) {
          if (index == 0) {
            return LoginScreen(
              controller: controller,
            );
          } else if (index == 1) {
            return BottomBar(
              controller: controller,
            );
          }  else {
            return VerifyScreen(
              controller: controller,
            );
          }
        },
      ),
    );
  }
}
