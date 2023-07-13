import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';

Future<T?> popBottomSheet<T>({
  required BuildContext context,
  required String title,
  String info = "",
  bool mayKeyboardAppear = false,
  required List<Widget> Function(StateSetter) bottomWidgets,
  void Function()? onSheetDismissed,
  Object? stateObject,
}) async {
  const minPadding = EdgeInsets.fromLTRB(12, 16, 12, 32);
  return await showModalBottomSheet<T?>(
      context: context,
      isScrollControlled: true,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: MyTextStyles.font_16_20_500,
                    ),
                  ),
                  if (info.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        info,
                        textAlign: TextAlign.center,
                        style: MyTextStyles.font_14_16_400,
                      ),
                    ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: bottomWidgets(setSheetState),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      });
}
