import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/pages/result_page.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:provider/provider.dart';

class FavouriteTile extends StatelessWidget {
  final Stop stop;
  final controller = TextEditingController();

  FavouriteTile({Key key, this.stop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context);
    return ListTile(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                elevation: 10,
                title: Text(
                  "Rename Stop",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).accentColor),
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
                    child: Text("Close"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text("Save",
                        style: TextStyle(color: Theme.of(context).accentColor)),
                    onPressed: () {
                      controller.value.text == ""
                          ? stop.customName = null
                          : stop.customName = controller.value.text;
                      prefs.updateCustomName(stop);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      },
      title: Text(
        stop.customName ?? stop.name.split(", ")[0],
        style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor),
      ),
      subtitle: Text(
        stop.stopNumber,
        style: const TextStyle(height: 1.5, fontSize: 16.0),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: "Result Page"),
                builder: (context) => ResultPage(stop: stop)));
      },
    );
  }
}
