import 'dart:async';

import 'package:flutter/material.dart';

Future<T?> popDialog<T>({required BuildContext context, required List<Widget> children, int? fadeDurationInMiliSecs}) async {
  return await showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        if (fadeDurationInMiliSecs != null) {
          Timer(Duration(milliseconds: fadeDurationInMiliSecs), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(24),
          contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          surfaceTintColor: Colors.white70,
          children: children,
        );
      });
}
