import 'package:flutter/material.dart';
import 'package:kelime_hazinem/screens/main_screen/homepage.dart';

class MainScreenTabBar extends StatefulWidget {
  const MainScreenTabBar({super.key});

  final tabLabelStyle = const TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w500,
  );

  @override
  State<MainScreenTabBar> createState() => _MainScreenTabBarState();
}

class _MainScreenTabBarState extends State<MainScreenTabBar> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      animationDuration: const Duration(milliseconds: 400),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF007AFF),
          toolbarHeight: 0,
          primary: false,
          bottom: TabBar(
            indicatorWeight: 2,
            indicatorColor: const Color(0xFFADE8F4),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: widget.tabLabelStyle,
            unselectedLabelStyle: widget.tabLabelStyle,
            labelColor: const Color(0xFFFFFFFF),
            unselectedLabelColor: const Color.fromRGBO(255, 255, 255, 0.8),
            tabs: const [
              Tab(height: 48, child: Center(child: Text('Anasayfa', textAlign: TextAlign.center))),
              Tab(height: 48, child: Center(child: Text('Listelerim', textAlign: TextAlign.center))),
              Tab(height: 48, child: Center(child: Text('Tüm Kelimeler', textAlign: TextAlign.center))),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomePage(),
            Text("data 2"),
            Text("data 3"),
          ],
        ),
      ),
    );
  }
}
