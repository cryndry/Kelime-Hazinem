import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/app_bars/list_selection_app_bar.dart';
import 'package:kelime_hazinem/components/app_bars/secondary_app_bar.dart';
import 'package:kelime_hazinem/components/app_bars/word_selection_app_bar.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/navigation_observer.dart';
import 'package:kelime_hazinem/utils/providers.dart';
import 'package:kelime_hazinem/utils/set_state_on_pop_next.dart';

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
  static const double appBarHeight = 64;

  @override
  Size get preferredSize => const Size.fromHeight(appBarHeight);

  @override
  MyAppBarState createState() => MyAppBarState();
}

class MyAppBarState extends ConsumerStateWithRefreshOnPopNext<MyAppBar> {  
  @override
  Widget build(BuildContext context) {
    final canPop = MyNavigatorObserver.stack.length > 1;
    final isListSelectionModeActive = ref.watch(isListSelectionModeActiveProvider);
    final isWordSelectionModeActive = ref.watch(isWordSelectionModeActiveProvider);

    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints.tightFor(height: 64),
          color: MyColors.darkBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppBar(
            toolbarHeight: MyAppBar.appBarHeight,
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
        SecondaryAppBar(
          child: isListSelectionModeActive
              ? const ListSelectionAppBar()
              : isWordSelectionModeActive
                  ? const WordSelectionAppBar()
                  : const SizedBox(),
        ),
      ],
    );
  }
}
