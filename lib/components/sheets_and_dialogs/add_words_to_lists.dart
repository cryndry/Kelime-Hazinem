import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/bottom_sheet.dart';
import 'package:kelime_hazinem/components/buttons/fill_colored_button.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/deep_map_copy.dart';

Future<void> addWordsToLists({required BuildContext context, required List<int> wordIds}) async {
  Map<int, Map<String, dynamic>> listsBottomSheet = {};

  for (int wordId in wordIds) {
    await SqlDatabase.getListsOfWord(wordId).then((value) {
      listsBottomSheet[wordId] = deepMapCopy(value);
    });
  }

  List<String> lists = await SqlDatabase.getLists();
  Map<String, bool> listDatas = {};
  for (String list in lists) {
    bool isAllWordsInList = true;
    for (var listDataOfWord in listsBottomSheet.values) {
      if (!listDataOfWord[list]["is_word_in_list"]) {
        isAllWordsInList = false;
        break;
      }
    }
    listDatas[list] = isAllWordsInList;
  }

  await popBottomSheet<bool>(
    context: context,
    title: "Listelere Ekle",
    info: """
      Listelerin işareti kaldırılsa bile kelimeler o listeden kaldırılmaz.
      (Birden çok kelime seçildiğinde geçerlidir)
    """,
    routeName: "AddWordsToListsBottomSheet",
    onSheetDismissed: () {},
    bottomWidgets: (setSheetState) {
      return [
        ConstrainedBox(
          constraints: BoxConstraints.loose(Size.fromHeight(MediaQuery.of(context).size.height * 0.5)),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final MapEntry listEntry = listDatas.entries.elementAt(index);
              return CheckboxListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                value: listDatas[listEntry.key],
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setSheetState(() {
                    listDatas[listEntry.key] = value!;
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
            for (MapEntry<int, Map<String, dynamic>> wordData in listsBottomSheet.entries) {
              final wordId = wordData.key;
              final listsDataOfWord = wordData.value;
              for (MapEntry<String, bool> listData in listDatas.entries) {
                final listName = listData.key;
                if (listData.value) {
                  listsDataOfWord[listName]["is_word_in_list"] = true;
                }
              }
              await SqlDatabase.changeListsOfWord(wordId, listsDataOfWord);
            }

            Navigator.of(context).pop(true);
          },
        ),
      ];
    },
  );
}
