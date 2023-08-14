import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
  required BuildContext context,
  required String message,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: MyDurations.millisecond1000,
      content: Text(message, style: MyTextStyles.font_16_20_400),
    ),
  );
}
