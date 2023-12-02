import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class SecondaryAppBar extends ConsumerWidget {
  const SecondaryAppBar({super.key, this.child = const Row()});

  final Widget child;
  static const double appBarHeight = MyAppBar.appBarHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnimatable = KeyValueDatabase.getIsAnimatable();
    final isListSelectionModeActive = ref.watch(isListSelectionModeActiveProvider);
    final isWordSelectionModeActive = ref.watch(isWordSelectionModeActiveProvider);

    final secondaryAppBar = Container(
      constraints: const BoxConstraints.tightFor(height: appBarHeight),
      color: MyColors.darkBlue,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: child,
    );

    return (isAnimatable)
        ? AnimatedPositioned(
            left: 0,
            right: 0,
            top: (isListSelectionModeActive || isWordSelectionModeActive) ? 0 : -appBarHeight,
            duration: MyDurations.millisecond300,
            child: secondaryAppBar,
          )
        : Positioned(
            left: 0,
            right: 0,
            top: (isListSelectionModeActive || isWordSelectionModeActive) ? 0 : -appBarHeight,
            child: secondaryAppBar,
          );
  }
}
