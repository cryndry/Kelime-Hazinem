import 'package:flutter/material.dart';

Future<void> popBottomSheet({
  required BuildContext context,
  required String title,
  String info = "",
  bool mayKeyboardAppear = false,
  required List<Widget> Function(StateSetter) bottomWidgets,
  void Function()? onSheetDismissed,
}) async {
  const minPadding = EdgeInsets.fromLTRB(12, 16, 12, 32);
  await showModalBottomSheet(
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
                      style: const TextStyle(
                        fontSize: 16,
                        height: 20 / 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (info.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        info,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 18 / 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  const SizedBox(height: 48),
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
