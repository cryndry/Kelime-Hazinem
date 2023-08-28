import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/about_dialog.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/dialog.dart';
import 'package:kelime_hazinem/screens/main_screen/tab_bar_navigation.dart';
import 'package:kelime_hazinem/utils/app_info.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppInfo.isAppInitializedNow) {
      Timer(MyDurations.millisecond1000, () {
        popDialog(
          context: context,
          routeName: "ActivateNotificationsDialog",
          builder: (setDialogState) {
            return [
              const Text(
                "Kelime Hazinem için\nbildirimleri etkinleştir",
                textAlign: TextAlign.center,
                style: MyTextStyles.font_18_20_500,
              ),
              const SizedBox(height: 12),
              const Text(
                "Bildirimleri etkinleştirerek günlük kelime bildirimleri alabilir, yepyeni kelimelerle tanışabilirsin.",
                textAlign: TextAlign.center,
                style: MyTextStyles.font_16_20_400,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text("Kapat"),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      KeyValueDatabase.setNotifications(true);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Onayla"),
                  ),
                ],
              )
            ];
          },
        );
      });
    }
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
