import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/dialog.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/components/stroke_colored_button.dart';
import 'package:kelime_hazinem/main.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';

Future<void> requestDisablingBatteryOptimization() async {
  bool? isBatOptDisabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled;
  bool? isManBatOptDisabled = await DisableBatteryOptimization.isManufacturerBatteryOptimizationDisabled;
  if (!(isBatOptDisabled == true && isManBatOptDisabled == true)) {
    final context = KelimeHazinem.navigatorKey.currentContext!;
    await popDialog(
      context: context,
      routeName: "BatteryOptimizationDialog",
      builder: (setDialogState) => [
        const Text(
          "Kelime Hazinem için batarya tasarrufunu devre dışı bırak",
          textAlign: TextAlign.center,
          style: MyTextStyles.font_18_20_500,
        ),
        const SizedBox(height: 12),
        const Text(
          "Batarya tasarrufunu devre dışı bırakmak bildirimlerin doğru bir şekilde çalışmasını sağlar.",
          textAlign: TextAlign.center,
          style: MyTextStyles.font_14_16_400,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StrokeColoredButton(
                title: "Vazgeç",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FillColoredButton(
                title: "Onayla",
                onPressed: () async {
                  await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
