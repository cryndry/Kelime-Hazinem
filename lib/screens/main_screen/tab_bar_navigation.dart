import 'package:flutter/material.dart';
import 'package:kelime_hazinem/screens/main_screen/all_words.dart';
import 'package:kelime_hazinem/screens/main_screen/homepage.dart';
import 'package:kelime_hazinem/screens/main_screen/my_lists.dart';

class MainScreenTabBar extends StatelessWidget {
  const MainScreenTabBar({super.key, required this.firstTabIndex, required this.setActiveTabIndex});

  final int firstTabIndex;
  final void Function(int) setActiveTabIndex;

  final tabLabelStyle = const TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: firstTabIndex,
      animationDuration: const Duration(milliseconds: 400),
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);
          controller.addListener(() {
            if (!controller.indexIsChanging) {
              setActiveTabIndex(controller.index);
            }
          });

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF007AFF),
              toolbarHeight: 0,
              primary: false,
              bottom: TabBar(
                indicatorWeight: 2,
                indicatorColor: const Color(0xFFADE8F4),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: tabLabelStyle,
                unselectedLabelStyle: tabLabelStyle,
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
                MyLists(),
                AllWords(),
              ],
            ),
          );
        },
      ),
    );
  }
}
