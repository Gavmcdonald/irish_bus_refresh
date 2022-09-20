import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:provider/provider.dart';

class IOSAlertDialog extends StatelessWidget {
  IOSAlertDialog({
    Key key,
    @required this.stop,
  }) : super(key: key);

  final Stop stop;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).colorScheme.primary;
    Prefs prefs = Provider.of<Prefs>(context, listen: false);
    return CupertinoAlertDialog(
      title: Text(
        "Rename Stop",
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor),
      ),
      content: CupertinoTextField(
        autofocus: true,
        controller: controller,
        placeholder: stop.name.split(", ")[0],
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        CupertinoDialogAction(
          child: Text("Save", style: TextStyle(color: textColor)),
          onPressed: () {
            controller.value.text == ""
                ? stop.customName = ""
                : stop.customName = controller.value.text;
            prefs.updateCustomName(stop);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
