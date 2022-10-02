import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:irish_bus_refresh/widgets/result_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Network extends ChangeNotifier {
  final _client = http.Client();
  List<Widget> _results = [];
  bool _isLoading = false;
  bool showScheduledDepartures = false;
  bool _hasConnection = false;
  DateTime _lastSynced;
  String _statusMessage = '';

  List<Widget> get stopResults => _results;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  bool get hasConnection => _hasConnection;

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showScheduledDepartures =
        (prefs.getBool('showScheduledDepartures') ?? false);
  }

  Future<void> getStopData(String stopId) async {
    _results = [];
    _isLoading = true;
    notifyListeners();

    DateTime now = DateTime.now();

    int year = now.year;
    int month = now.month;
    int day = now.day;

    String monthString = month < 10 ? "0$month" : month.toString();
    try {
      //print('https://journeyplanner.transportforireland.ie/nta/XML_DM_REQUEST?coordOutputFormat=WGS84%5Bdd.ddddd%5D&language=ie&std3_suggestMacro=std3_suggest&std3_commonMacro=dm&includeCompleteStopSeq=1&mergeDep=1&mode=direct&useAllStops=1&type_dm=any&nameInfo_dm=$stopId&itdDateDayMonthYear=$day.$monthString.$year&itdLPxx_snippet=1&itdLPxx_template=dmresults&outputFormat=rapidJSON');
      final response = await _client.get(
          'https://journeyplanner.transportforireland.ie/nta/XML_DM_REQUEST?coordOutputFormat=WGS84%5Bdd.ddddd%5D&language=ie&std3_suggestMacro=std3_suggest&std3_commonMacro=dm&includeCompleteStopSeq=1&mergeDep=1&mode=direct&useAllStops=1&type_dm=any&nameInfo_dm=$stopId&itdLPxx_snippet=1&itdLPxx_template=dmresults&outputFormat=rapidJSON');

      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);

        if (parsed['stopEvents'] == null) {
          _isLoading = false;
          _results = [];
          notifyListeners();
        }

        for (var result in parsed['stopEvents']) {
          int dueMins = DateTime.parse(result['departureTimePlanned'])
              .difference(now)
              .inMinutes;
          int min = DateTime.parse(result['departureTimePlanned']).minute;
          String minute = min < 10 ? '0$min' : '$min';

          if (result["isRealtimeControlled"] != null) {
            if (dueMins <= 1) {
              _results.add(ResultTile(
                  departureTime: 'now',
                  destination: result['transportation']['destination']['name'],
                  route: result['transportation']['disassembledName']));
            } else if (dueMins <= 60) {
              _results.add(ResultTile(
                  departureTime: '$dueMins mins',
                  destination: result['transportation']['destination']['name'],
                  route: result['transportation']['disassembledName']));
            } else {
              _results.add(ResultTile(
                  departureTime:
                      '${DateTime.parse(result['departureTimePlanned']).hour}:$minute',
                  destination: result['transportation']['destination']['name'],
                  route: result['transportation']['disassembledName']));
            }
          } else if (result["isRealtimeControlled"] == null &&
              showScheduledDepartures) {
            _results.add(ResultTile(
                departureTime:
                    '${DateTime.parse(result['departureTimePlanned']).hour}:$minute',
                destination: result['transportation']['destination']['name'],
                route: result['transportation']['disassembledName']));
          }
        }
        _lastSynced = DateTime.now();

        if (_lastSynced != null) {
          String hour = _lastSynced.hour > 9
              ? _lastSynced.hour.toString()
              : '0${_lastSynced.hour}';
          String minute = _lastSynced.minute > 9
              ? _lastSynced.minute.toString()
              : '0${_lastSynced.minute}';

          _statusMessage = "Last synced $hour:$minute";
        } else if (_lastSynced == null) {
          _statusMessage = "";
        }
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _hasConnection = false;
        notifyListeners();
        throw Exception("Failed to Load Station Data");
      }

      // lastSynced = DateTime.now();
      // minutesSincelastSync();
      // loading = false;
      // notifyListeners();
    } catch (e) {
      // statusMessage = "Failed to connect.";
      // loading = false;
      // notifyListeners();
    }
  }

  checkForInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      _hasConnection = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      _hasConnection = true;
    } else {
      _hasConnection = false;
    }
  }
}
