import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/getX/ProfileController.dart';
import 'package:stikev/getX/RouteController.dart';
import 'package:stikev/screens/dasboard/profile/profile_screen.dart';
import 'package:stikev/screens/dasboard/routes/route_screen.dart';
import 'package:stikev/screens/dasboard/statistics/statistics_screen.dart';
import 'package:stikev/utils/main_style.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key, required this.controller});
  final PageController controller;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  final LoginController _loginController = Get.put(LoginController());
  final ProfileController _profileController = Get.put(ProfileController());
  
  @override
  void initState() {
    super.initState();
    _profileController.displayProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _getSelectedWidget(),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navBarItems,
      ),
    );
  }

  Widget _getSelectedWidget() {
    switch (_selectedIndex) {
      case 0:
        return StatisticsScreen(); // Pestaña de estadísticas
      case 1:
        return RoutesWidget(); // Pestaña de rutas
      case 2:
        return const ProfilePage1(); // Pestaña de perfil
      default:
        return Container();
    }
  }
}


final _navBarItems = [
  SalomonBottomBarItem(
      icon: const Icon(Icons.bar_chart),
      title: const Text("Estadísticas"),
      selectedColor: AppStyles.thirdColor),
  SalomonBottomBarItem(
    icon: const Icon(Icons.home),
    title: const Text("Rutas"),
    selectedColor: AppStyles.thirdColor, // Color de fondo azul
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.person),
    title: const Text("Perfil"),
    selectedColor: AppStyles.thirdColor, // Color de fondo azul
  ),
];
