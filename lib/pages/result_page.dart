import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:irish_bus_refresh/widgets/result_tile.dart';
import 'package:provider/provider.dart';
class ResultPage extends StatefulWidget {
  const ResultPage({Key key, @required this.stop}) : super(key: key);

  final Stop stop;

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  List<Widget> _results = [];
  final _client = http.Client();

  @override
  initState(){
    getStopData(widget.stop.name);
    print('${widget.stop.stopNumber}');
    super.initState();
  }

  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
            IconButton(
            padding: const EdgeInsets.all(0),
            icon: prefs.favourites.contains(widget.stop)
                ? const Icon(
                    Icons.star,
                    color: Colors.white,
                  )
                : const Icon(
                    Icons.star_border,
                    color: Colors.white,
                  ),
            onPressed: () {
              prefs.toggleFavourite(widget.stop);
            },
          )
        ],
        title: Text(widget.stop.name.split(", ")[0]),
      ),
      body: _results.isEmpty & !_loading ? const Text('No Busses :(') : Center(
        child: _loading ? const CircularProgressIndicator() : ListView(children: _results,)
      ),
    );
  }

  Future<void> getStopData(String stopId) async {
    setState(() {
      _loading = true;
    });

    int year = DateTime.now().year;
    int month = DateTime.now().month;
    int day = DateTime.now().day;

    String monthString = month < 10 ? "0$month" : month.toString();

    print(monthString);
    /////////THIS IS THE WORKING CODE FOR RETRIEVING RESULTS FROM SMARTDUBLIN
    try {
      final response = await _client.get('https://journeyplanner.transportforireland.ie/nta/XML_DM_REQUEST?coordOutputFormat=WGS84%5Bdd.ddddd%5D&language=ie&std3_suggestMacro=std3_suggest&std3_commonMacro=dm&includeCompleteStopSeq=1&mergeDep=1&mode=direct&useAllStops=1&type_dm=any&nameInfo_dm=$stopId&itdDateDayMonthYear=$day.$monthString.$year&itdLPxx_snippet=1&itdLPxx_template=dmresults&outputFormat=rapidJSON');
      print('https://journeyplanner.transportforireland.ie/nta/XML_DM_REQUEST?coordOutputFormat=WGS84%5Bdd.ddddd%5D&language=ie&std3_suggestMacro=std3_suggest&std3_commonMacro=dm&includeCompleteStopSeq=1&mergeDep=1&mode=direct&useAllStops=1&type_dm=any&nameInfo_dm=$stopId&itdDateDayMonthYear=$day.$monthString.$year&itdLPxx_snippet=1&itdLPxx_template=dmresults&outputFormat=rapidJSON');
      
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);

        print("code 200");

        print(parsed[''].runtimeType);

        if(parsed['stopEvents'] == null){
          setState(() {
            _loading = false;
            _results = [];
          });
        }

        for (var result in parsed['stopEvents']) {
          int min = DateTime.parse(result['departureTimePlanned']).minute;
          String minute = min < 10 ? '0$min' : '$min';
          _results.add(ResultTile(
            departureTime: '${DateTime.parse(result['departureTimePlanned']).hour}:$minute',
            destination: result['transportation']['destination']['name'],
            route: result['transportation']['disassembledName']
          ));
        }

        setState(() {
          _results = _results;
          _loading = false;
        });

      } else {
        setState(() {
          _loading = false;
        });
        throw Exception("Failed to Load Station Data");
      }

      // lastSynced = DateTime.now();
      // minutesSincelastSync();
      // loading = false;
      // notifyListeners();
    } catch (e) {
      print(e.toString());
      // statusMessage = "Failed to connect.";
      // loading = false;
      // notifyListeners();
    }
  }


}



