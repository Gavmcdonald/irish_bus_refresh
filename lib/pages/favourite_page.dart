import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:irish_bus_refresh/widgets/stop_tile.dart';
import 'package:provider/provider.dart';


class FavouritesPage extends StatelessWidget {
  const FavouritesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context);

    if(prefs.favourites.isEmpty){
      return Center(
        child: Text("You haven't added any favourites yet")
      );
    }

    return Container( 
      child: ReorderableListView(
        onReorder: (old_index, new_index) {
          var favourite = prefs.favourites[old_index];
          prefs.favourites.removeAt(old_index);
          print("$old_index and $new_index");

          if(old_index > new_index){
            print(" old less than new");
            prefs.favourites.insert(new_index, favourite);
            print(prefs.favourites.length);
          }

          else if(new_index > prefs.favourites.length){
            prefs.favourites.add(favourite);
          }
          else{
            prefs.favourites.insert(new_index-1, favourite);
          }

          
          prefs.saveFavourites();
        },
        padding: EdgeInsets.all(4),
        children: [
          for (var favourite in prefs.favourites) 
            StopTile(stop: favourite, key: ValueKey(favourite),)
        ],
      ),
      




      // child: ListView.builder(
      //   padding: EdgeInsets.all(4.0),
      //   itemCount: prefs.favourites.length,
      //   itemBuilder: (context, i) {
      //     return StopTile(
      //       stop: prefs.favourites[i],
      //     );
      //   },
      // )
    );
  }
}