import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/route_animator.dart';
import 'package:kelime_hazinem/main.dart';
import 'package:kelime_hazinem/screens/main_screen/tab_bar_navigation.dart';
import 'package:kelime_hazinem/screens/settings.dart';
import 'package:kelime_hazinem/screens/share_lists.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> with RouteAware {
  int lastTabIndex = KeyValueDatabase.getFirstTabIndex();

  @override
  void didPushNext() {
    ref.read(activeTabIndexProvider.notifier).update((state) {
      lastTabIndex = state;
      return -1;
    });

    super.didPushNext();
  }

  @override
  void didPopNext() {
    ref.read(activeTabIndexProvider.notifier).update((state) => lastTabIndex);

    super.didPushNext();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

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
                Navigator.of(context).push(
                  routeAnimator(page: const ShareLists()),
                );
              },
            ),
            ActionButton(
              key: const ValueKey("settings"),
              icon: MySvgs.settings,
              size: 32,
              semanticsLabel: "Ayarlar",
              onTap: () {
                Navigator.of(context).push(
                  routeAnimator(page: const Settings()),
                );
              },
            ),
          ],
        ),
        body: const MainScreenTabBar(),
      ),
    );
  }
}
