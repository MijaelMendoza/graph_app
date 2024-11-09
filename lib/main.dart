import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grafos/UI/home.dart';

void main() {
  // Bloquear orientación en horizontal
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para inicializar los servicios antes de runApp
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}
