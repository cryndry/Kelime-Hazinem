import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/screens/main_screen/all_words.dart';
import 'package:kelime_hazinem/screens/main_screen/homepage.dart';
import 'package:kelime_hazinem/screens/main_screen/my_lists.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class MainScreenTabBar extends ConsumerWidget {
  const MainScreenTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      initialIndex: KeyValueDatabase.getFirstTabIndex(),
      animationDuration: MyDurations.millisecond400,
      child: Builder(builder: (context) {
        final controller = DefaultTabController.of(context);
        controller.addListener(() {
          if (!controller.indexIsChanging) {
            ref.read(activeTabIndexProvider.notifier).update((state) => controller.index);
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
      }),
    );
  }
}
