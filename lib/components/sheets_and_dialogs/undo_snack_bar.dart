import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/others/circular_progress_with_duration.dart';
import 'package:kelime_hazinem/main.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';

void showUndoSnackBar({
  required String message,
  required Duration duration,
  required void Function() undoCallback,
  required void Function() noUndoCallback,
  void Function()? snackBarClosedCallback,
}) {
  Timer? timer;

  BuildContext context = KelimeHazinem.navigatorKey.currentContext!;

  ScaffoldMessenger.of(context).clearSnackBars();
  final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      padding: const EdgeInsets.all(8),
      backgroundColor: MyColors.darkBlue,
      duration: duration,
      onVisible: () {
        if (timer != null) {
          timer?.cancel();
          timer = null;
        }
        timer = Timer(duration, noUndoCallback);
      },
      content: Row(
        children: [
          TextButton.icon(
            label: Text("Geri Al", style: MyTextStyles.font_14_16_500.apply(color: Colors.white)),
            style: const ButtonStyle(overlayColor: MaterialStatePropertyAll(Colors.white24)),
            icon: CircularProgressIndicatorWithDuration(
              size: 30,
              strokeWidth: 3,
              color: Colors.white,
              duration: duration,
              shouldShowRemainingDuration: true,
              remainingDurationColor: Colors.white,
            ),
            onPressed: () {
              timer?.cancel();
              timer = null;
              undoCallback();
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
          const SizedBox(width: 4),
          Text(message, style: MyTextStyles.font_16_20_400),
        ],
      ),
    ),
  );

  snackBarController.closed.then((SnackBarClosedReason reason) {
    snackBarClosedCallback?.call();
  });
}
