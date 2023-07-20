import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/bottom_sheet.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/deep_map_copy.dart';

Future<void> addWordToLists({required BuildContext context, required int wordId}) async {
  Map<String, dynamic> listsBottomSheet = {};

  await SqlDatabase.getListsOfWord(wordId).then((value) {
    listsBottomSheet.addAll(deepMapCopy(value));
  });

  popBottomSheet<Map<String, dynamic>>(
    context: context,
    title: "Listelere Ekle",
    info: "Liste değişiklikleri kaydettikten sonra geri alınamaz.",
    routeName: "AddToListsBottomSheet",
    bottomWidgets: (setSheetState) {
      return [
        ConstrainedBox(
          constraints: BoxConstraints.loose(Size.fromHeight(MediaQuery.of(context).size.height * 0.5)),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: listsBottomSheet.length,
            itemBuilder: (context, index) {
              final MapEntry listEntry = listsBottomSheet.entries.elementAt(index);
              return CheckboxListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                value: listEntry.value["is_word_in_list"],
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setSheetState(() {
                    listsBottomSheet[listEntry.key]["is_word_in_list"] = value;
                  });
                },
                title: Text(
                  listEntry.key,
                  style: MyTextStyles.font_16_20_500,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        FillColoredButton(
          title: "Kaydet",
          onPressed: () async {
            await SqlDatabase.changeListsOfWord(wordId, listsBottomSheet);
            Navigator.of(context).pop();
          },
        ),
      ];
    },
  );
}
