import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:irish_bus_refresh/widgets/stop_tile.dart';
import 'package:provider/provider.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context);

    if (prefs.favourites.isEmpty) {
      return const Center(child: Text("You haven't added any favourites yet"));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
      child: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          var favourite = prefs.favourites[oldIndex];
          prefs.favourites.removeAt(oldIndex);

          if (oldIndex > newIndex) {
            prefs.favourites.insert(newIndex, favourite);
          } else if (newIndex > prefs.favourites.length) {
            prefs.favourites.add(favourite);
          } else {
            prefs.favourites.insert(newIndex - 1, favourite);
          }

          prefs.saveFavourites();
        },
        padding: const EdgeInsets.all(4),
        children: [
          for (var favourite in prefs.favourites)
            StopTile(
              stop: favourite,
              key: ValueKey(favourite),
            )
        ],
      ),
    );
  }

  getPadding() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const EdgeInsets.only(top: 32);
    }

    return const EdgeInsets.fromLTRB(0, 0, 0, 0);
  }
}
