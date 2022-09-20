import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/stop.dart';
import '../services/prefs.dart';
import 'android_alert_dialog.dart';

class AndroidPopupMenu extends StatelessWidget {
  const AndroidPopupMenu({Key key, this.stop}) : super(key: key);
  final Stop stop;

  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context, listen: false);
    return PopupMenuButton<String>(
      onSelected: (selection) {
        if (selection == "Rename") {
          showDialog(
              context: context,
              builder: (context) {
                return AndroidAlertDialog(
                  stop: stop,
                );
              });
        }

        if (selection == "Clear Custom Name") {
          stop.customName = "";
          prefs.updateCustomName(stop);
        }
      },
      itemBuilder: (BuildContext context) {
        List<String> options = ["Rename", "Clear Custom Name"];
        return options.map((String option) {
          return PopupMenuItem<String>(
            enabled: prefs.favourites.contains(stop),
            value: option,
            child: Text(option),
          );
        }).toList();
      },
    );
  }
}
