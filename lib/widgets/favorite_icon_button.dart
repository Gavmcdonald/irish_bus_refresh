import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:provider/provider.dart';

class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({
    Key key, @required this.stop,

  }) : super(key: key);

  final Stop stop;

  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context);
    return IconButton(
      padding: const EdgeInsets.all(0),
      icon: prefs.favourites.contains(stop)
          ? Icon(
              Icons.star,
              color: Theme.of(context).colorScheme.primary,
            )
          : Icon(
              Icons.star_border,
              color: Theme.of(context).colorScheme.primary,
            ),
      onPressed: () {
        prefs.toggleFavourite(stop);
      },
    );
  }
}