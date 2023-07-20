import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/screens/main_screen/tab_bar_navigation.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: 'Kelime Hazinem',
          buttons: [
            ActionButton(
              key: const ValueKey("cloud"),
              icon: MySvgs.cloud,
              size: 32,
              semanticsLabel: "Liste Paylaş",
              onTap: () {
                Navigator.of(context).pushNamed("ShareLists");
              },
            ),
            ActionButton(
              key: const ValueKey("settings"),
              icon: MySvgs.settings,
              size: 32,
              semanticsLabel: "Ayarlar",
              onTap: () {
                Navigator.of(context).pushNamed("Settings");
              },
            ),
          ],
        ),
        body: const MainScreenTabBar(),
      ),
    );
  }
}
