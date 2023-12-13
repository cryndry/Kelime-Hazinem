import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/buttons/stroke_colored_button.dart';
import 'package:kelime_hazinem/screens/other_screens/settings.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/set_state_on_pop_next.dart';
import 'package:pie_chart/pie_chart.dart';

class MyPerformance extends StatefulWidget {
  const MyPerformance({super.key});

  @override
  MyPerformanceState createState() => MyPerformanceState();
}

class MyPerformanceState extends StateWithRefreshOnPopNext<MyPerformance> {
  String period = KeyValueDatabase.getMyPerformancePeriod();
  Map<String, double> data = {
    "willLearnCount": 0,
    "favoriteCount": 0,
    "learnedCount": 0,
    "memorizedCount": 0,
  };

  void setCountOfWordAttrs() {
    SqlDatabase.getCountOfWordAttrs(period: period).then((value) {
      setState(() {
        data = {
          "willLearnCount": value["willLearnCount"]!.toDouble(),
          "favoriteCount": value["favoriteCount"]!.toDouble(),
          "learnedCount": value["learnedCount"]!.toDouble(),
          "memorizedCount": value["memorizedCount"]!.toDouble(),
        };
      });
    });
  }

  String getNoDataMessage() {
    switch (period) {
      case "Haftalık":
        return "Bu hafta bir çalışma yapmamışsın gibi görünüyor. Her gün 5 dakikanı ayırarak bilgilerini zinde tutabilirsin.";
      case "Aylık":
        return "Uzun süredir buralarda değilsin. Biraz vaktini ayırarak bilgilerini zinde tutabilirsin.";
      case "3 Aylık":
        return "Seni görmeyi çok özledik. Hemen birkaç kelimeye göz atmak ister misin?";
      default:
        return "";
    }
  }

  @override
  void initState() {
    setOnPopNextCallback(setCountOfWordAttrs);
    setCountOfWordAttrs();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MyColors.darkBlue.withOpacity(0.7),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Performansım", style: MyTextStyles.font_20_24_600.apply(color: MyColors.darkBlue)),
              SelectableSetting(
                values: const {
                  "Haftalık": "Haftalık",
                  "Aylık": "Aylık",
                  "3 Aylık": "3 Aylık",
                },
                initialValue: period,
                color: MyColors.darkBlue,
                onChange: (value) {
                  KeyValueDatabase.setMyPerformancePeriod(value);
                  setState(() {
                    period = value;
                  });
                  setCountOfWordAttrs();
                },
              )
            ],
          ),
          data.values.reduce((value, element) => (value + element)) == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      getNoDataMessage(),
                      style: MyTextStyles.font_16_24_500.apply(
                        color: MyColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StrokeColoredButton(
                      title: "Kısa Bir Tekrar?",
                      onPressed: () async {
                        final doesWillLearnHaveEnoughWords = await SqlDatabase.checkIfIconicListHaveWords(
                          listName: "willLearn",
                          atLeast: KeyValueDatabase.getWordLearnListLength(),
                        );
                        Navigator.of(context).pushNamed(
                          "WordLearn",
                          arguments: (doesWillLearnHaveEnoughWords)
                              ? {
                                  "listName": "Öğreneceklerim",
                                  "dbTitle": "willLearn",
                                }
                              : {
                                  "listName": "Temel Seviye",
                                  "dbTitle": "Temel Seviye",
                                },
                        );
                      },
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data["willLearnCount"] != 0)
                          Text(
                            "Öğreneceklerim: ${data["willLearnCount"]!.toInt()}",
                            style: MyTextStyles.font_16_24_500.apply(
                              color: const Color(0xFFFF453A),
                            ),
                          ),
                        if (data["favoriteCount"] != 0)
                          Text(
                            "Favorilerim: ${data["favoriteCount"]!.toInt()}",
                            style: MyTextStyles.font_16_24_500.apply(
                              color: const Color(0xFFFF9F0A),
                            ),
                          ),
                        if (data["learnedCount"] != 0)
                          Text(
                            "Öğrendiklerim: ${data["learnedCount"]!.toInt()}",
                            style: MyTextStyles.font_16_24_500.apply(
                              color: const Color(0xFF32D74B),
                            ),
                          ),
                        if (data["memorizedCount"] != 0)
                          Text(
                            "Hazinem: ${data["memorizedCount"]!.toInt()}",
                            style: MyTextStyles.font_16_24_500.apply(
                              color: MyColors.darkGreen,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    PieChart(
                      dataMap: data,
                      chartRadius: 96,
                      chartType: ChartType.disc,
                      initialAngleInDegree: 180,
                      animationDuration: MyDurations.millisecond1000,
                      legendOptions: const LegendOptions(showLegends: false),
                      chartValuesOptions: const ChartValuesOptions(showChartValues: false),
                      colorList: const [
                        MyColors.red,
                        MyColors.amber,
                        MyColors.green,
                        MyColors.darkGreen,
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
