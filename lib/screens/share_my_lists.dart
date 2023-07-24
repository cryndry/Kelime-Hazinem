import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/screens/main_screen/my_lists.dart';

class ShareMyLists extends StatelessWidget {
  const ShareMyLists({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        appBar: MyAppBar(title: "Listelerim"),
        body: MyLists(),
      ),
    );
  }
}
