import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs with ChangeNotifier {

  Prefs() {
    _loadFavourites();
  }
  List<Stop> _favourites = [];

  List<Stop> get favourites => _favourites;
  static const String favouriteKey = 'favouriteKey';

  /// Adds stop to favourites list if there isn't already a stop with a matching stop
  _addStop(Stop stop) {
    if(!favourites.contains(stop)){
      _favourites.add(stop);
      notifyListeners();
    }
  }

  updateCustomName(Stop stop){
    
    favourites.firstWhere((Stop liststop) => liststop.stopNumber == stop.stopNumber).customName = stop.customName;
    notifyListeners();
    saveFavourites();
  }

  /// Removes any favourites that have a matching stop number
  _removeStop(Stop stop){
    _favourites.remove(stop);
    notifyListeners();
    }

  
  toggleFavourite(Stop stop){
    _favourites.contains(stop)? _removeStop(stop) : _addStop(stop);
    saveFavourites();
  }

  saveFavourites() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(favouriteKey, jsonEncode(_favourites));
  notifyListeners();
}

  _loadFavourites() async {

    print('loading');

    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString(favouriteKey) ?? '';
    if(data != ''){
      Iterable retrieved = json.decode(data);
      _favourites = retrieved.map((stop)=> Stop.fromJson(stop)).toList();
      notifyListeners();
    }
   }


}
