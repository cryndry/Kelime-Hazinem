import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const MyAppBar(
          title: "Ayarlar",
        ),
        body: PageLayout(
          children: <SettingRow>[
            SettingRow(
              title: "Açılış Ekranı",
              child: SelectableSetting<int>(
                values: const {
                  0: "Anasayfa",
                  1: "Listelerim",
                  2: "Tüm Kelimeler",
                },
                initialValue: KeyValueDatabase.getFirstTabIndex(),
                onChange: (newValue) {
                  KeyValueDatabase.setFirstTabIndex(newValue);
                },
              ),
            ),
            SettingRow(
              title: "Bildirimler",
              child: SwitchSetting(
                initialValue: KeyValueDatabase.getNotifications(),
                onChange: (bool newValue) {
                  KeyValueDatabase.setNotifications(newValue);
                },
              ),
            ),
            SettingRow(
              title: "Karanlık Mod",
              child: SwitchSetting(
                initialValue: KeyValueDatabase.getDarkMode(),
                onChange: (bool newValue) {
                  KeyValueDatabase.setDarkMode(newValue);
                },
              ),
            ),
            SettingRow(
              title: "Animasyonlar",
              child: SwitchSetting(
                initialValue: KeyValueDatabase.getIsAnimatable(),
                onChange: (bool newValue) {
                  KeyValueDatabase.setIsAnimatable(newValue);
                },
              ),
            ),
            SettingRow(
              title: "Kelime Öğrenme modu liste uzunluğu",
              info: "(en\xA0az\xA020 - en\xA0fazla\xA0200)",
              child: NumericSetting(
                min: 20,
                max: 200,
                initialValue: KeyValueDatabase.getWordLearnListLength(),
                onChange: (int newValue) {
                  KeyValueDatabase.setWordLearnListLength(newValue);
                },
              ),
            ),
            SettingRow(
              title: "Diğer modlarda liste uzunluğu",
              info: "(en\xA0az\xA010 - en\xA0fazla\xA0100)",
              child: NumericSetting(
                min: 10,
                max: 100,
                initialValue: KeyValueDatabase.getOtherModsListLength(),
                onChange: (int newValue) {
                  KeyValueDatabase.setOtherModsListLength(newValue);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.title,
    this.info,
    required this.child,
  });

  final String title;
  final String? info;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: MyTextStyles.font_18_20_500),
                  if (info != null) const SizedBox(height: 4),
                  if (info != null)
                    Text(
                      info!,
                      style: MyTextStyles.font_16_20_400.merge(const TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                        letterSpacing: 0,
                      )),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class NumericSetting extends StatefulWidget {
  const NumericSetting({
    super.key,
    required this.initialValue,
    required this.onChange,
    required this.min,
    required this.max,
  });

  final int initialValue;
  final void Function(int) onChange;
  final int min;
  final int max;

  @override
  State<NumericSetting> createState() => NumericSettingState();
}

class NumericSettingState extends State<NumericSetting> {
  late int state = widget.initialValue;
  late final textEditingController = TextEditingController(text: widget.initialValue.toString());
  final textInputFocus = FocusNode();

  void changeHandler() {
    final int value = int.parse(textEditingController.text);
    if (value < widget.min || value > widget.max) {
      textEditingController.text = state.toString();
    } else {
      setState(() {
        state = value;
      });
      widget.onChange(value);
    }

    textInputFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black26),
        ],
      ),
      child: IntrinsicWidth(
        child: TextField(
          showCursor: true,
          focusNode: textInputFocus,
          style: MyTextStyles.font_20_24_500,
          autocorrect: false,
          keyboardType: TextInputType.number,
          controller: textEditingController,
          onEditingComplete: () {
            changeHandler();
          },
          onTapOutside: (event) {
            if (textInputFocus.hasFocus) {
              changeHandler();
            }
          },
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class SwitchSetting extends StatefulWidget {
  const SwitchSetting({
    super.key,
    required this.initialValue,
    required this.onChange,
  });

  final bool initialValue;
  final void Function(bool) onChange;

  @override
  State<SwitchSetting> createState() => SwitchSettingState();
}

class SwitchSettingState extends State<SwitchSetting> {
  late bool state = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 56,
      child: Switch(
        activeTrackColor: MyColors.darkBlue,
        inactiveTrackColor: Colors.black.withOpacity(0.6),
        thumbColor: const MaterialStatePropertyAll(Colors.white),
        value: state,
        onChanged: (value) {
          setState(() {
            widget.onChange(value);
            state = value;
          });
        },
      ),
    );
  }
}

class SelectableSetting<T> extends StatefulWidget {
  const SelectableSetting({
    super.key,
    required this.values,
    required this.initialValue,
    required this.onChange,
  });

  final Map<T, String> values;
  final T initialValue;
  final void Function(T) onChange;

  @override
  State<SelectableSetting> createState() => SelectableSettingState<T>();
}

class SelectableSettingState<T> extends State<SelectableSetting<T>> {
  late T state = widget.initialValue;

  final TextStyle textStyle = MyTextStyles.font_16_20_400.merge(const TextStyle(color: Colors.black));

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      initialValue: state,
      position: PopupMenuPosition.over,
      surfaceTintColor: Colors.white,
      tooltip: "Açılış Ekranını Değiştir",
      itemBuilder: (context) {
        return widget.values
            .map((key, value) => MapEntry(
                  // key: tabIndex, value: tabName
                  key,
                  PopupMenuItem<T>(
                    value: key,
                    onTap: () {
                      setState(() {
                        widget.onChange(key);
                        state = key;
                      });
                    },
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: textStyle,
                    ),
                  ),
                ))
            .values
            .toList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Text(widget.values[state]!, style: textStyle),
            const SizedBox(width: 4),
            const ActionButton(
              icon: MySvgs.littleDownArrow,
              size: 20,
              strokeColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
