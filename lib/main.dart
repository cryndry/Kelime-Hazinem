import 'package:flutter/material.dart';
import 'package:kelime_hazinem/screens/main_screen/main_screen.dart';
import 'package:kelime_hazinem/utils/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqlDatabase.initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Hazinem',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
