import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/route_animator.dart';
import 'package:kelime_hazinem/screens/main_screen/main_screen.dart';
import 'package:kelime_hazinem/screens/settings.dart';
import 'package:kelime_hazinem/screens/share_lists.dart';
import 'package:kelime_hazinem/screens/share_my_lists.dart';
import 'package:kelime_hazinem/screens/word_screen/all_words_of_list.dart';
import 'package:kelime_hazinem/screens/word_screen/word_add.dart';
import 'package:kelime_hazinem/screens/word_screen/word_edit.dart';
import 'package:kelime_hazinem/screens/word_screen/word_guess.dart';
import 'package:kelime_hazinem/screens/word_screen/word_learn.dart';
import 'package:kelime_hazinem/screens/word_screen/word_show.dart';
import 'package:kelime_hazinem/screens/word_screen/word_test.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/navigation_observer.dart';
import 'package:kelime_hazinem/utils/providers.dart';
import 'package:kelime_hazinem/notifications/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqlDatabase.initDB();
  await KeyValueDatabase.initDB();
  runApp(const ProviderScope(child: KelimeHazinem()));
  await FirebaseDatabase.initDB();
  await Notifications.initService();
  if (await Notifications.isNotificationAllowed()) {
    final time = KeyValueDatabase.getNotificationTime();
    await Notifications.createDailyWordNotification(time);
  }
}

final routeObserver = RouteObserver();

class KelimeHazinem extends ConsumerWidget {
  const KelimeHazinem({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SqlDatabase.getLists().then((result) {
        result.remove("Temel Seviye");
        result.remove("Orta Seviye");
        result.remove("İleri Seviye");

        ref.read(myListsProvider.notifier).update((state) => result);
      });
    });

    return MaterialApp(
      title: 'Kelime Hazinem',
      theme: ThemeData(
        fontFamily: "Manrope",
        useMaterial3: true,
        colorSchemeSeed: MyColors.darkBlue,
      ),
      navigatorKey: navigatorKey,
      navigatorObservers: [MyNavigatorObserver(), routeObserver],
      initialRoute: "/",
      onGenerateRoute: (settings) {
        final String? routeName = settings.name;
        final arguments = settings.arguments as Map<String, dynamic>?;

        switch (routeName) {
          case "/":
            return routeAnimator(page: const MainScreen());
          case "MyLists":
            return routeAnimator(page: const ShareMyLists());
          case "WordLearn":
            return routeAnimator(
              beginOffset: arguments!["beginOffset"],
              page: WordLearn(
                listName: arguments["listName"],
                dbTitle: arguments["dbTitle"],
              ),
            );
          case "WordTest":
            return routeAnimator(
              beginOffset: arguments!["beginOffset"],
              page: WordTest(
                listName: arguments["listName"],
                dbTitle: arguments["dbTitle"],
              ),
            );
          case "WordGuess":
            return routeAnimator(
              beginOffset: arguments!["beginOffset"],
              page: WordGuess(
                listName: arguments["listName"],
                dbTitle: arguments["dbTitle"],
              ),
            );
          case "AllWordsOfList":
            return routeAnimator(
              beginOffset: arguments!["beginOffset"],
              page: AllWordsOfList(
                listName: arguments["listName"],
                dbTitle: arguments["dbTitle"],
              ),
            );
          case "WordAdd":
            return routeAnimator(page: const WordAdd());
          case "WordEdit":
            return routeAnimator(page: WordEdit(word: arguments!["word"]));
          case "WordShow":
            return routeAnimator(page: WordShow(word: arguments!["word"]));
          case "ShareLists":
            return routeAnimator(page: const ShareLists());
          case "Settings":
            return routeAnimator(page: const Settings());
        }
        return null;
      },
    );
  }
}
