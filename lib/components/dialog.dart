import 'dart:async';
import 'package:flutter/material.dart';

Future<T?> popDialog<T>({
  required BuildContext context,
  required List<Widget> Function(StateSetter) builder,
  int? fadeDurationInMiliSecs,
  String? routeName,
  void Function()? onDialogDissmissed,
}) async {
  return await showDialog<T>(
    context: context,
    routeSettings: RouteSettings(name: routeName),
    builder: (BuildContext context) {
      if (fadeDurationInMiliSecs != null) {
        Timer(Duration(milliseconds: fadeDurationInMiliSecs), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      }
      return StatefulBuilder(builder: (context, setDialogState) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(24),
          contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          surfaceTintColor: Colors.white70,
          children: builder(setDialogState),
        );
      });
    },
  ).then((dialogPopResult) {
    if (onDialogDissmissed != null) {
      onDialogDissmissed();
    }
    return dialogPopResult;
  });
}
