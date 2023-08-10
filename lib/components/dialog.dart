import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/circular_progress_with_duration.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';

Future<T?> popDialog<T>({
  required BuildContext context,
  required List<Widget> Function(StateSetter) builder,
  Duration? duration,
  String? routeName,
  void Function()? onDialogDissmissed,
}) async {
  return await showDialog<T>(
    context: context,
    routeSettings: RouteSettings(name: routeName),
    builder: (BuildContext dialogContext) {
      if (duration != null) {
        Timer(duration, () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });
      }
      return StatefulBuilder(builder: (dialogContext, setDialogState) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(24),
          contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          surfaceTintColor: Colors.white70,
          children: [
            ...builder(setDialogState),
            if (duration != null) const SizedBox(height: 12),
            if (duration != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Row(
                      children: [
                        Text("Kapat", style: MyTextStyles.font_16_24_500),
                        SizedBox(width: 12),
                        CircularProgressIndicatorWithDuration(
                          size: 24,
                          strokeWidth: 3,
                          color: MyColors.darkBlue,
                          duration: MyDurations.millisecond1000,
                        ),
                        SizedBox(width: 12),
                      ],
                    ),
                    onPressed: () {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                  ),
                ],
              ),
          ],
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
