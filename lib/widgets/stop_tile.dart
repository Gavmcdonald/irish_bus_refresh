import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/pages/result_page.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:provider/provider.dart';

class StopTile extends StatelessWidget {
  final Stop stop;
  final controller = TextEditingController();

  StopTile({this.stop, ValueKey<Stop> key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context);
    return ListTile(
      title: Text(
        stop.customName == "" ? stop.name.split(', ')[0] : stop.customName,
        style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary),
      ),
      subtitle: Text(
        stop.stopNumber ?? '',
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
