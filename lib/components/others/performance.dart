import 'package:flutter/material.dart';
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
        color: MyColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Performansım", style: MyTextStyles.font_20_24_600.apply(color: Colors.white)),
              SelectableSetting(
                values: const {
                  "Haftalık": "Haftalık",
                  "Aylık": "Aylık",
                  "3 Aylık": "3 Aylık",
                },
                initialValue: "Haftalık",
                color: Colors.white,
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
                    Text(
                      getNoDataMessage(),
                      style: MyTextStyles.font_16_24_500.apply(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                        foregroundColor: MaterialStatePropertyAll(MyColors.darkBlue),
                        padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 4, horizontal: 8)),
                      ),
                      child: const Text("Kısa Bir Tekrar?", style: MyTextStyles.font_16_20_500),
                      onPressed: () async {
                        final doesWillLearnHaveEnoughWords =
                            await SqlDatabase.checkIfIconicListHaveWords("willLearn", 50);
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
                              color: MyColors.red,
                            ),
                          ),
                        if (data["favoriteCount"] != 0)
                          Text(
                            "Favorilerim: ${data["favoriteCount"]!.toInt()}",
                            style: MyTextStyles.font_16_24_500.apply(
                              color: MyColors.amber,
                            ),
                          ),
                        if (data["learnedCount"] != 0)
                          Text(
                            "Öğrendiklerim: ${data["learnedCount"]!.toInt()}",
                            style: MyTextStyles.font_16_24_500.apply(
                              color: MyColors.green,
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
