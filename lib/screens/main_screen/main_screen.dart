import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/screens/main_screen/tab_bar_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  final String title = 'Kelime Hazinem';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: widget.title,
        ),
        body: const MainScreenTabBar(),
      ),
    );
  }
}
