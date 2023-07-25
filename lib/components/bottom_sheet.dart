import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';

Future<T?> popBottomSheet<T>({
  required BuildContext context,
  required String title,
  Widget? widgetBetweenTitleAndInfo,
  String info = "",
  bool mayKeyboardAppear = false,
  required List<Widget> Function(StateSetter) bottomWidgets,
  void Function()? onSheetDismissed,
  String? routeName,
}) async {
  const minPadding = EdgeInsets.fromLTRB(32, 16, 32, 32);
  final vievport = MediaQuery.of(context).size;
  return await showModalBottomSheet<T?>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    routeSettings: RouteSettings(name: routeName),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Container(
            padding: mayKeyboardAppear
                ? minPadding + EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)
                : minPadding,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
              color: Colors.white,
            ),
            constraints: BoxConstraints(
              minWidth: vievport.width,
              maxWidth: vievport.width,
              maxHeight: vievport.height,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: MyTextStyles.font_16_20_500,
                  ),
                ),
                if (widgetBetweenTitleAndInfo != null) widgetBetweenTitleAndInfo,
                if (info.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      info,
                      textAlign: TextAlign.center,
                      style: MyTextStyles.font_14_16_400,
                    ),
                  ),
                const SizedBox(height: 32),
                ...bottomWidgets(setSheetState),
              ],
            ),
          );
        },
      );
    },
  ).then((value) {
    if (onSheetDismissed != null) {
      onSheetDismissed();
    }
    return value;
  });
}
