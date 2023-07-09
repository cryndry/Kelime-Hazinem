import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/route_animator.dart';
import 'package:kelime_hazinem/screens/settings.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

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

  late List<ActionButton> firstOrSecondTabButtons = [
    ActionButton(
      key: const ValueKey("cloud"),
      icon: MySvgs.cloud,
      size: 32,
      semanticsLabel: "Liste Paylaş",
      onTap: () {},
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
  ];

  late List<ActionButton> thirdTabButtons = [
    ActionButton(
      key: const ValueKey("search"),
      icon: MySvgs.search,
      size: 32,
      semanticsLabel: "Kelime Ara",
      onTap: () {},
    ),
    ...firstOrSecondTabButtons,
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
    final canPop = Navigator.canPop(context);
    return Container(
      constraints: const BoxConstraints.tightFor(height: 64),
      color: const Color(0xFF007AFF),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: AppBar(
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
        titleSpacing: canPop ? 12 : 0,
        title: widget.secTitle == null
            ? Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  height: 32 / 22,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 20 / 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.secTitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 16 / 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
        leadingWidth: 32,
        leading: canPop
            ? ActionButton(
                icon: MySvgs.backArrow,
                size: 32,
                onTap: () {
                  Navigator.pop(context);
                },
              )
            : null,
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
    );
  }
}
