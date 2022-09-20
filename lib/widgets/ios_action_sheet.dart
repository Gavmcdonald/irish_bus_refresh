import 'package:flutter/cupertino.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:provider/provider.dart';

import 'ios_alert_dialog.dart';

class IOSActionSheet extends StatelessWidget {
  const IOSActionSheet({Key key, @required this.stop}) : super(key: key);

  final Stop stop;

  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context, listen: false);
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
            onPressed: (() => {
                  showCupertinoDialog(
                      context: context,
                      builder: ((context) => IOSAlertDialog(stop: stop)))
                }),
            child: const Text("Rename Stop")),
        CupertinoActionSheetAction(
            onPressed: () {
              stop.customName = "";
              prefs.updateCustomName(stop);
            },
            child: const Text("Clear Custom Name")),
      ],

      //TODO: add in the option to hide or show scheduled departures
      cancelButton: CupertinoActionSheetAction(
        child: const Text("Close"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
