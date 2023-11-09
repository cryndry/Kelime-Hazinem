import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/bottom_sheet.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:social_share/social_share.dart';

Future<void> shareWord({required BuildContext context, required Word word}) async {
  await popBottomSheet(
    context: context,
    title: "Kelimeni Paylaş",
    bottomWidgets: (setSheetState) {
      Widget buttonWidget({
        required Color color,
        required String icon,
        required Future<void> Function() onTap,
      }) =>
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
              child: ActionButton(icon: icon, size: 36),
            ),
          );

      final descrData = word.description.isEmpty
          ? ''
          : word.description.startsWith("Ç")
              ? "Çoğulu: ${word.description.substring(3)}\n"
              : "Mastarı: ${word.description.substring(3)}\n";
      final messageText = "Kelime: ${word.word}\n${descrData}Anlamı: ${word.meaning}\n\nDaha fazlası Kelime Hazinem uygulamasında!\nhttps://play.google.com/store/apps/details?id=com.kelime_hazinem.ar_tr";
      
      return [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            buttonWidget(
              color: Colors.grey[700]!,
              icon: MySvgs.copy,
              onTap: () async {
                await SocialShare.copyToClipboard(text: messageText);
                Navigator.of(context).pop();
              },
            ),
            buttonWidget(
              color: const Color(0xFF25D366),
              icon: MySvgs.whatsapp,
              onTap: () async {
                await SocialShare.shareWhatsapp(messageText);
                Navigator.of(context).pop();
              },
            ),
            buttonWidget(
              color: const Color(0xFF00ACEE),
              icon: MySvgs.twitter,
              onTap: () async {
                await SocialShare.shareTwitter(messageText);
                Navigator.of(context).pop();
              },
            ),
            buttonWidget(
              color: const Color(0xFF64B4F0),
              icon: MySvgs.telegram,
              onTap: () async {
                await SocialShare.shareTelegram(messageText);
                Navigator.of(context).pop();
              },
            ),
            buttonWidget(
              color: MyColors.darkBlue,
              icon: MySvgs.sms,
              onTap: () async {
                await SocialShare.shareSms(messageText);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ];
    },
  );
}
