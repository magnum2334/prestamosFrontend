import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:stikev/main_view.dart';

void main() async {
  runApp(
    DevicePreview(
      builder: (context) => const MyApp(),
      data: DevicePreviewData(
        deviceIdentifier: Devices.ios.iPhone13ProMax.toString(),
        isFrameVisible: false,
        locale: 'fr_FR',
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: const MainView());
  }
}
