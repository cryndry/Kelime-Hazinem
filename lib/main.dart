import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/route_animator.dart';
import 'package:kelime_hazinem/screens/main_screen/main_screen.dart';
import 'package:kelime_hazinem/screens/settings.dart';
import 'package:kelime_hazinem/screens/share_lists.dart';
import 'package:kelime_hazinem/screens/word_screen/all_words_of_list.dart';
import 'package:kelime_hazinem/screens/word_screen/word_add.dart';
import 'package:kelime_hazinem/screens/word_screen/word_edit.dart';
import 'package:kelime_hazinem/screens/word_screen/word_guess.dart';
import 'package:kelime_hazinem/screens/word_screen/word_learn.dart';
import 'package:kelime_hazinem/screens/word_screen/word_test.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/navigation_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqlDatabase.initDB();
  await KeyValueDatabase.initDB();
  runApp(const ProviderScope(child: KelimeHazinem()));
}

class KelimeHazinem extends StatelessWidget {
  const KelimeHazinem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Hazinem',
      theme: ThemeData(
        fontFamily: "Manrope",
        useMaterial3: true,
        colorSchemeSeed: MyColors.darkBlue,
      ),
      navigatorObservers: [MyNavigatorObserver()],
      initialRoute: "/",
      onGenerateRoute: (settings) {
        final String? routeName = settings.name;
        final arguments = settings.arguments as Map<String, dynamic>?;

        switch (routeName) {
          case "/":
            return routeAnimator(page: const MainScreen());
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
