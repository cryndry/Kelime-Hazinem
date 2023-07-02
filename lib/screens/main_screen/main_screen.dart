import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/screens/main_screen/tab_bar_navigation.dart';
import 'package:kelime_hazinem/utils/database.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  static String title = 'Kelime Hazinem';
  final int firstTabIndex = KeyValueDatabase.getFirstTabIndex();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int activeTabIndex = widget.firstTabIndex;

  void setActiveTabIndex(int index) {
    setState(() {
      activeTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: MainScreen.title,
          activeTabIndex: activeTabIndex,
        ),
        body: MainScreenTabBar(
          firstTabIndex: widget.firstTabIndex,
          setActiveTabIndex: setActiveTabIndex,
        ),
      ),
    );
  }
}
