import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs with ChangeNotifier {
  Prefs() {
    _loadFavourites();
    _checkShowScheduledDepartures();
    _getPackageInfo();
  }
  List<Stop> _favourites = [];
  bool _showScheduledDepartures = false;
  String _version = "";
  String _buildNumber = "";

  String get version => _version;
  String get buildNumber => _buildNumber;

  List<Stop> get favourites => _favourites;
  bool get showScheduledDepartures => _showScheduledDepartures;
  static const String favouriteKey = 'favouriteKey';

  /// Adds stop to favourites list if there isn't already a stop with a matching stop
  _addStop(Stop stop) {
    if (!favourites.contains(stop)) {
      _favourites.add(stop);
      notifyListeners();
    }
  }

  updateCustomName(Stop stop) {
    favourites
        .firstWhere((Stop liststop) => liststop.stopNumber == stop.stopNumber)
        .customName = stop.customName;
    notifyListeners();
    saveFavourites();
  }

  /// Removes any favourites that have a matching stop number
  _removeStop(Stop stop) {
    _favourites.remove(stop);
    notifyListeners();
  }

  toggleFavourite(Stop stop) {
    _favourites.contains(stop) ? _removeStop(stop) : _addStop(stop);
    saveFavourites();
  }

  saveFavourites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(favouriteKey, jsonEncode(_favourites));
    notifyListeners();
  }

  _loadFavourites() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString(favouriteKey) ?? '';
    if (data != '') {
      Iterable retrieved = json.decode(data);
      _favourites = retrieved.map((stop) => Stop.fromJson(stop)).toList();
      notifyListeners();
    }
  }

  toggleShowScheduledDepartures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('showScheduledDepartures', !_showScheduledDepartures);
    _showScheduledDepartures = !_showScheduledDepartures;
    notifyListeners();
  }

  _checkShowScheduledDepartures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _showScheduledDepartures =
        (prefs.getBool('showScheduledDepartures') ?? false);
    notifyListeners();
  }

  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    notifyListeners();
  }
}
