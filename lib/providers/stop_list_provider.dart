import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import '../assets/route_data.dart';

class StopList extends ChangeNotifier {
  List<Stop> _listOfAllStops;
  List<Stop> _filteredStopList;

  StopList() {
    List<Stop> parsedStopData = [];
    String data = routeData;
    var parsed = json.decode(data);
    for (var stop in parsed) {
      parsedStopData.add(Stop.fromJson(stop));
    }
    _listOfAllStops = parsedStopData;
    _filteredStopList = _listOfAllStops;
  }

  List<Stop> get filteredStopList => _filteredStopList;

  filterStopList(String query) {
    if (query == "") {
      _filteredStopList = _listOfAllStops;
      notifyListeners();
    } else {
      _filteredStopList = _listOfAllStops
          .where(
              (stop) => stop.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if(_filteredStopList.isEmpty){
        _filteredStopList = _listOfAllStops;
      }
      notifyListeners();
    }
  }
}
