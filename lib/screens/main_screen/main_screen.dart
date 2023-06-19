import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/screens/main_screen/tab_bar_navigation.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static String title = 'Kelime Hazinem';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: title,
        ),
        body: const MainScreenTabBar(),
      ),
    );
  }
}
