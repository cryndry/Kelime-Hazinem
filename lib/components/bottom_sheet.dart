import 'package:flutter/material.dart';

void popBottomSheet(BuildContext context, String title, String info, List<Widget> buttons) {
  print("screen width: " + MediaQuery.of(context).size.width.toString());
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 20 / 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (info.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    info,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 18 / 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: buttons,
                ),
              ),
            ],
          ),
        );
      });
}
