import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/screens/main_screen/main_screen.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqlDatabase.initDB();
  await KeyValueDatabase.initDB();
  runApp(const ProviderScope(child: KelimeHazinem()));
}

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class KelimeHazinem extends StatelessWidget {
  const KelimeHazinem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Hazinem',
      home: const MainScreen(),
      theme: ThemeData(
        fontFamily: "Manrope",
        useMaterial3: true,
        colorSchemeSeed: MyColors.darkBlue,
      ),
      navigatorObservers: [routeObserver],
    );
  }
}
