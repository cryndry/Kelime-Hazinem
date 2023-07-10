import 'package:flutter/material.dart';
import 'package:kelime_hazinem/screens/main_screen/all_words.dart';
import 'package:kelime_hazinem/screens/main_screen/homepage.dart';
import 'package:kelime_hazinem/screens/main_screen/my_lists.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';

class MainScreenTabBar extends StatelessWidget {
  const MainScreenTabBar({super.key, required this.firstTabIndex, required this.setActiveTabIndex});

  final int firstTabIndex;
  final void Function(int) setActiveTabIndex;

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
              backgroundColor: MyColors.darkBlue,
              toolbarHeight: 0,
              primary: false,
              bottom: TabBar(
                indicatorWeight: 2,
                indicatorColor: MyColors.aqua,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: MyTextStyles.font_14_16_500,
                unselectedLabelStyle: MyTextStyles.font_14_16_500,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.8),
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
