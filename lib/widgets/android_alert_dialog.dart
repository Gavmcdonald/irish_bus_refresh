import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:provider/provider.dart';

class AndroidAlertDialog extends StatelessWidget {
  AndroidAlertDialog({
    Key key,
    @required this.stop
  }) : super(key: key);
    
  final controller = TextEditingController();
  final Stop stop;

  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context);
    return AlertDialog(
      elevation: 10,
      title: Text(
        "Rename Stop",
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      content: TextField(
        autofocus: true,
        controller: controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4)),
            hintText: stop.name.split(", ")[0]),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("Save",
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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