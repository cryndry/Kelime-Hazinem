import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/components/buttons/fill_colored_button.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/layouts/page_layout.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/dialog.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/notifications.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const MyAppBar(title: "Ayarlar"),
        body: PageLayout(
          children: [
            SettingRow(
              title: "Açılış Ekranı",
              child: SelectableSetting<int>(
                key: const ValueKey("Açılış Ekranı"),
                values: const {
                  0: "Anasayfa",
                  1: "Listelerim",
                  2: "Tüm Kelimeler",
                },
                tooltip: "Açılış Ekranını Değiştir",
                initialValue: KeyValueDatabase.getFirstTabIndex(),
                onChange: (newValue) {
                  KeyValueDatabase.setFirstTabIndex(newValue);
                },
              ),
            ),
            SettingRow(
              title: "Animasyonlar",
              child: SwitchSetting(
                key: const ValueKey("Animasyonlar"),
                initialValue: KeyValueDatabase.getIsAnimatable(),
                onChange: (bool newValue) {
                  return KeyValueDatabase.setIsAnimatable(newValue);
                },
              ),
            ),
            SettingRow(
              title: "Bildirimler",
              child: SwitchSetting(
                key: const ValueKey("Bildirimler"),
                initialValue: KeyValueDatabase.getNotifications(),
                onChange: (bool newValue) {
                  final change = KeyValueDatabase.setNotifications(newValue);
                  change.then((value) {
                    setState(() {});
                  });
                  return change;
                },
              ),
            ),
            if (KeyValueDatabase.getNotifications())
              SettingRow(
                title: "Günlük Bildirim Saati",
                info: "Pil tasarrufu vb. sebeplerle bu özellik düzgün çalışmayabilir.",
                child: TimePickSetting(
                  key: const ValueKey("Günlük Bildirim Saati"),
                  initialValue: KeyValueDatabase.getNotificationTime(),
                  onChange: (value) {
                    Notifications.createDailyWordNotification(value);
                    KeyValueDatabase.setNotificationTime(value);
                  },
                ),
              ),
            SettingRow(
              title: "Kelime Öğrenme modu liste uzunluğu",
              info: "(en\xA0az\xA020 - en\xA0fazla\xA0200)",
              child: NumericSetting(
                key: const ValueKey("Kelime Öğrenme modu liste uzunluğu"),
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
                key: const ValueKey("Diğer modlarda liste uzunluğu"),
                min: 10,
                max: 100,
                initialValue: KeyValueDatabase.getOtherModsListLength(),
                onChange: (int newValue) {
                  KeyValueDatabase.setOtherModsListLength(newValue);
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(blurRadius: 4, color: Colors.black26),
                ],
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  const Text(
                    "Verilerini taşımak istiyorsan buraya!",
                    style: MyTextStyles.font_16_24_500,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final String? message = await SqlDatabase.importDBFile();
                            if (message != null) {
                              await popDialog(
                                context: context,
                                duration: MyDurations.millisecond1000 * 3,
                                routeName: "RestoreCompleteDialog",
                                builder: (setDialogState) {
                                  return [
                                    Text(
                                      message,
                                      textAlign: TextAlign.center,
                                      style: MyTextStyles.font_18_20_500,
                                    ),
                                    const SizedBox(height: 8),
                                  ];
                                },
                              );
                            }
                          },
                          child: FillColoredButton(
                            title: "Geri Yükle",
                            icon: const ActionButton(
                              icon: MySvgs.import,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final isSuccessful = await SqlDatabase.exportDBFile();
                            if (isSuccessful) {
                              await popDialog(
                                context: context,
                                duration: MyDurations.millisecond1000 * 3,
                                routeName: "BackupCompleteDialog",
                                builder: (setDialogState) {
                                  return const [
                                    Text(
                                      "Yedekleme Başarılı",
                                      textAlign: TextAlign.center,
                                      style: MyTextStyles.font_18_20_500,
                                    ),
                                    SizedBox(height: 8),
                                  ];
                                },
                              );
                            }
                          },
                          child: FillColoredButton(
                            title: "Yedekle",
                            icon: const ActionButton(
                              icon: MySvgs.export,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
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
  late int state;
  late final TextEditingController textEditingController;
  final textInputFocus = FocusNode();

  @override
  void initState() {
    state = widget.initialValue;
    textEditingController = TextEditingController(text: widget.initialValue.toString());

    super.initState();
  }

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
  final Future<bool> Function(bool) onChange;

  @override
  State<SwitchSetting> createState() => SwitchSettingState();
}

class SwitchSettingState extends State<SwitchSetting> {
  late bool state;

  @override
  void initState() {
    state = widget.initialValue;

    super.initState();
  }

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
        onChanged: (value) async {
          final newState = await widget.onChange(value);
          setState(() {
            state = newState;
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
    this.color = Colors.black,
    this.tooltip = "",
  });

  final Map<T, String> values;
  final T initialValue;
  final void Function(T) onChange;
  final Color color;
  final String tooltip;

  @override
  State<SelectableSetting> createState() => SelectableSettingState<T>();
}

class SelectableSettingState<T> extends State<SelectableSetting<T>> {
  late T state;
  final TextStyle textStyle = MyTextStyles.font_16_20_400;

  @override
  void initState() {
    state = widget.initialValue;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      initialValue: state,
      position: PopupMenuPosition.over,
      surfaceTintColor: Colors.white,
      tooltip: widget.tooltip,
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
            Text(widget.values[state]!, style: textStyle.apply(color: widget.color)),
            const SizedBox(width: 4),
            ActionButton(
              icon: MySvgs.littleDownArrow,
              size: 20,
              strokeColor: widget.color,
            ),
          ],
        ),
      ),
    );
  }
}

class TimePickSetting extends StatefulWidget {
  const TimePickSetting({
    super.key,
    required this.initialValue,
    required this.onChange,
  });

  final String initialValue;
  final void Function(String) onChange;

  @override
  TimePickSettingState createState() => TimePickSettingState();
}

class TimePickSettingState extends State<TimePickSetting> {
  late TimeOfDay state;

  @override
  void initState() {
    state = Notifications.stringToTimeOfDay(widget.initialValue);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showTimePicker(
          context: context,
          initialTime: state,
          helpText: "",
          cancelText: "Vazgeç",
          confirmText: "Uygula",
          hourLabelText: "Saat",
          minuteLabelText: "Dakika",
          errorInvalidText: "Lütfen geçerli bir aralık girin",
          routeSettings: const RouteSettings(name: "NotificationTimePicker"),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (result is TimeOfDay) {
          widget.onChange(Notifications.timeOfDayToString(result));
          setState(() {
            state = result;
          });
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(blurRadius: 4, color: Colors.black26),
          ],
        ),
        child: Text(Notifications.timeOfDayToString(state), style: MyTextStyles.font_24_32_500),
      ),
    );
  }
}
