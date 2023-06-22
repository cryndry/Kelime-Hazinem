import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/icon.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    this.secTitle,
    this.buttons = const [],
    this.activeTabIndex,
  });

  final String title;
  final String? secTitle;
  final List<Widget> buttons;
  final double appBarHeight = 64;
  final int? activeTabIndex;

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  late List<Widget> buttons;
  static const firstOrSecondTabButtons = [
    ActionButton(
      path: "assets/Cloud.svg",
      size: 32,
      semanticsLabel: "Liste Paylaş",
    ),
    ActionButton(
      path: "assets/Settings.svg",
      size: 32,
      semanticsLabel: "Ayarlar",
    ),
  ];
  static const thirdTabButtons = [
    ActionButton(
      path: "assets/Search.svg",
      size: 32,
      semanticsLabel: "Kelime Ara",
    ),
    ...firstOrSecondTabButtons
  ];

  @override
  void initState() {
    if (widget.activeTabIndex != null) {
      buttons = (widget.activeTabIndex == 2) ? thirdTabButtons : firstOrSecondTabButtons;
    } else {
      buttons = widget.buttons;
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant MyAppBar oldWidget) {
    setState(() {
      if (widget.activeTabIndex != null) {
        buttons = (widget.activeTabIndex == 2) ? thirdTabButtons : firstOrSecondTabButtons;
      } else {
        buttons = widget.buttons;
      }
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        color: const Color(0xFF007AFF),
        padding: const EdgeInsets.all(16),
        child: AppBar(
          backgroundColor: const Color(0xFF007AFF),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              height: 32 / 22,
            ),
          ),
          foregroundColor: Colors.white,
          titleSpacing: 0,
          actions: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: (buttons.isNotEmpty) ? buttons.length * 40 - 8 : 0),
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => buttons[index],
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemCount: buttons.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
