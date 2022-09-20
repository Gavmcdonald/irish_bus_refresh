import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irish_bus_refresh/pages/map_page.dart';
import 'package:irish_bus_refresh/pages/settings_page.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppBar(
        toolbarHeight: 0,
        toolbarOpacity: 0,
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
      );
    }

    optionSelection(String selection) {
      if (selection == "Settings") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SettingsPage()));
      }
    }

    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark),
      elevation: 0,
      backgroundColor: Theme.of(context).canvasColor,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MapSample()));
          },
          icon: const Icon(Icons.location_pin),
          color: Theme.of(context).colorScheme.primary,
        ),
        PopupMenuButton<String>(
          icon:
              Icon(Icons.adaptive.more, color: Theme.of(context).colorScheme.primary),
          onSelected: optionSelection,
          itemBuilder: (BuildContext context) {
            List<String> options = ["Settings"];
            return options.map((String option) {
              return PopupMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList();
          },
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
