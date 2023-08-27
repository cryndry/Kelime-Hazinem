import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/dialog.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> popAboutDialog(BuildContext context) async {
  final packageInfo = await PackageInfo.fromPlatform();

  popDialog(
    context: context,
    routeName: "AboutDialog",
    builder: (setDialogState) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/app_logo_256x256.png",
                width: 64,
                height: 64,
                semanticLabel: "Kelime Hazinem logo",
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(packageInfo.appName, style: MyTextStyles.font_20_24_500),
                const SizedBox(height: 8),
                Text("Versiyon: ${packageInfo.version}", style: MyTextStyles.font_14_16_500),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 280),
            child: Text(
              "Uygulamamızın amacı Arapça öğrenen insanlara kelime ezberleme aşamasında kolay ulaşılabilen ve pratik bir yolla yardımcı olmaktır.",
              style: MyTextStyles.font_16_24_500.apply(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "İletişim",
          textAlign: TextAlign.center,
          style: MyTextStyles.font_20_24_500.apply(color: Colors.black87),
        ),
        TextButton(
          onPressed: () async {
            final uri = Uri(
              scheme: "mailto",
              path: "kelimehazinemm@gmail.com",
            );
            launchUrl(uri);
          },
          child: const Text(
            "kelimehazinemm@gmail.com",
            style: MyTextStyles.font_16_20_500,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: const Text("Lisanslar"),
              onPressed: () {
                showLicensePage(context: context);
              },
            ),
            TextButton(
              child: const Text("Gizlilik Politikası"),
              onPressed: () async {
                const url = "https://kelimehazinem.com/privacy-policy";
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
            ),
          ],
        ),
      ];
    },
  );
}
