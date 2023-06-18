import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kelime_hazinem/components/icon.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  MyAppBar({super.key, required this.title, this.secTitle, this.buttons});

  final String? title;
  final String? secTitle;
  final List<Widget>? buttons;
  final double height = 64;

  final Widget cloudIcon = SvgPicture.asset('assets/Cloud.svg',
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      semanticsLabel: 'Share lists');

  final Widget settingsIcon = SvgPicture.asset('assets/Settings.svg',
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      semanticsLabel: 'Settings');

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: const Color(0xFF007AFF),
          padding: const EdgeInsets.all(16),
          child: AppBar(
            backgroundColor: const Color(0xFF007AFF),
            title: Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 22,
                height: 32 / 22,
              ),
            ),
            foregroundColor: Colors.white,
            titleSpacing: 0,
            actions: const <Widget>[
              ActionButton(
                path: "assets/Cloud.svg",
                size: 32,
                semanticsLabel: "Liste Paylaş",
              ),
              SizedBox(width: 8),
              ActionButton(
                path: "assets/Settings.svg",
                size: 32,
                semanticsLabel: "Ayarlar",
              ),
            ],
          ),
        ),
    );
  }
}
