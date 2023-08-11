import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/secondary_app_bar.dart';
import 'package:kelime_hazinem/main.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/navigation_observer.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class MyAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    this.secTitle,
    this.buttons = const [],
  });

  final String title;
  final String? secTitle;
  final List<Widget> buttons;
  final double appBarHeight = 64;

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
  
  @override
  MyAppBarState createState() => MyAppBarState();
}

class MyAppBarState extends ConsumerState<MyAppBar> with RouteAware {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.unsubscribe(this);
    });
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final canPop = MyNavigatorObserver.stack.length > 1;
    final isAnimatable = KeyValueDatabase.getIsAnimatable();
    final isSelectionModeActive = ref.watch(isSelectionModeActiveProvider);
    final activeTabIndex = ref.watch(activeTabIndexProvider);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final bool isUsedInListSharePage = MyNavigatorObserver.stack.first == "ShareMyLists";
      if (!(activeTabIndex == 1 || isUsedInListSharePage)) {
        deactivateSelectionMode(ref);
      }
    });

    const secondaryAppBar = SecondaryAppBar();
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints.tightFor(height: 64),
          color: MyColors.darkBlue,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: AppBar(
            backgroundColor: MyColors.darkBlue,
            foregroundColor: Colors.white,
            centerTitle: false,
            titleSpacing: canPop ? 12 : 0,
            title: widget.secTitle == null
                ? Text(widget.title, style: MyTextStyles.font_24_32_500)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: MyTextStyles.font_18_20_500),
                      const SizedBox(height: 4),
                      Text(widget.secTitle!, style: MyTextStyles.font_14_16_500),
                    ],
                  ),
            leadingWidth: 32,
            leading: canPop
                ? ActionButton(
                    icon: MySvgs.backArrow,
                    size: 32,
                    semanticsLabel: "Geri Dön",
                    onTap: Navigator.of(context).pop,
                  )
                : null,
            actions: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: (widget.buttons.isNotEmpty) ? widget.buttons.length * 40 - 8 : 0),
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => widget.buttons[index],
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemCount: widget.buttons.length,
                ),
              ),
            ],
          ),
        ),
        if (isAnimatable)
          AnimatedPositioned(
            left: 0,
            right: 0,
            top: isSelectionModeActive ? 0 : -64,
            duration: MyDurations.millisecond300,
            child: secondaryAppBar,
          ),
        if (!isAnimatable && isSelectionModeActive) secondaryAppBar,
      ],
    );
  }
}
