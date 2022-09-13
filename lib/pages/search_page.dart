import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/assets/route_data.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/pages/result_page.dart';
import 'package:irish_bus_refresh/widgets/stop_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    List<Stop> allStopData = [];
    String data = routeData;
    var parsed = json.decode(data);

    for (var stop in parsed) {
      allStopData.add(Stop.fromJson(stop));
    }

    _data = allStopData;
    _filteredData = _data;
    super.initState();
  }

  final myController = TextEditingController();

  List _data = [];
  List _filteredData = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getPadding(),
      child: (Column(
        children: <Widget>[
          searchBox(),
          Flexible(
            child: ListView(
              children: [
                for (Stop stop in _filteredData)
                  StopTile(
                    stop: stop,
                    key: ValueKey(stop),
                  )
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget searchBox() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CupertinoSearchTextField(
          controller: myController,
          onChanged: (entered) => filterStopList(entered),
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: myController,
          onChanged: (entered) => filterStopList(entered),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.secondary),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            hintText: 'Enter Stop Name or Number',
            hintStyle:
                TextStyle(color: Theme.of(context).colorScheme.secondary),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
      );
    }
  }

  filterStopList(String query) {
    if (query == "") {
      setState(() {
        _filteredData = _data;
      });
    } else {
      setState(() {
        _filteredData = _data
            .where(
                (stop) => stop.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

    getPadding(){
    if(defaultTargetPlatform == TargetPlatform.iOS){
      return const EdgeInsets.only(top: 36);
    }

    return const EdgeInsets.fromLTRB(0, 0, 0, 0);
  }

  loadStopsFromAsset() {}
}
