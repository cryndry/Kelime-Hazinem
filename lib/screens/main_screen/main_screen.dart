import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/about_dialog.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/screens/main_screen/tab_bar_navigation.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
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
              icon: MySvgs.cloud,
              size: 32,
              semanticsLabel: "Liste Paylaş",
              onTap: () {
                Navigator.of(context).pushNamed("ShareLists");
              },
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: PopupMenuButton(
                tooltip: "Daha Fazla",
                padding: EdgeInsets.zero,
                icon: const ActionButton(icon: MySvgs.threeDots, size: 32),
                iconSize: 32,
                onSelected: (value) {
                  switch (value) {
                    case "Settings":
                      Navigator.of(context).pushNamed("Settings");
                      break;
                    case "AboutUs":
                      popAboutDialog(context);
                      break;
                    default:
                      break;
                  }
                },
                itemBuilder: (popupMenuContext) {
                  return [
                    PopupMenuItem(
                      value: "Settings",
                      child: Row(
                        children: [
                          const ActionButton(
                            icon: MySvgs.settings,
                            size: 32,
                            strokeColor: MyColors.darkBlue,
                            semanticsLabel: "Ayarlar",
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Ayarlar",
                            style: MyTextStyles.font_16_20_500.apply(
                              color: MyColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "AboutUs",
                      child: Row(
                        children: [
                          const ActionButton(
                            icon: MySvgs.info,
                            size: 32,
                            strokeColor: MyColors.darkBlue,
                            semanticsLabel: "Hakkımızda",
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Hakkımızda",
                            style: MyTextStyles.font_16_20_500.apply(
                              color: MyColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            )
          ],
        ),
        body: const MainScreenTabBar(),
      ),
    );
  }
}
