import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/widgets/theme_switcher.dart';
import 'package:provider/provider.dart';

import '../pages/privacy_policy.dart';
import '../services/prefs.dart';

class SettingsList extends StatefulWidget {
  const SettingsList({Key key}) : super(key: key);

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context);
    return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: ListTile(
                title: const Text("Show Scheduled Departures"),
                subtitle: const Text(
                    "Scheduled departures have no real time data and therefore may be more unreliable. "
                    "We filter these out by default to improve reliability."),
                isThreeLine: true,
                trailing: getCheckBox(prefs),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text("About App"),
              subtitle: Text("Version: ${prefs.version}\nBuild Number: ${prefs.buildNumber}"),
              isThreeLine: true,
            ),
            const Divider(),
            ListTile(
                title: const Text("Privacy Policy"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          settings: const RouteSettings(name: "Privacy Policy"),
                          builder: (context) => const PrivacyPolicy()));
                }),
                const Divider(),
            ListTile(title: const Text("Theme"), subtitle: ThemeSwitcher()),
            const Divider()
          ],
        );
  }

    Widget getCheckBox(prefs) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoSwitch(
          value: prefs.showScheduledDepartures,
          onChanged: (boo) => prefs.toggleShowScheduledDepartures());
    } else {
      return Checkbox(
        activeColor: Theme.of(context).colorScheme.primary,
          value: prefs.showScheduledDepartures,
          onChanged: (boo) {
            prefs.toggleShowScheduledDepartures();
          });
    }
  }
}