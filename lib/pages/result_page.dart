import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:irish_bus_refresh/widgets/android_popup_menu.dart';
import 'package:irish_bus_refresh/widgets/ios_action_sheet.dart';
import 'package:irish_bus_refresh/widgets/result_tile.dart';
import 'package:provider/provider.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/favorite_icon_button.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key key, @required this.stop}) : super(key: key);

  final Stop stop;

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final _client = http.Client();

  String statusMessage = "";
  DateTime lastSynced;

  List<Widget> _results = [];

  bool hasConnection = true;
  bool showScheduledDepartures = false;

  BannerAd _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoaded == false) {
      _loadAd();
    }
  }

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showScheduledDepartures =
          (prefs.getBool('showScheduledDepartures') ?? false);
    });
  }

  Future<void> _loadAd() async {
    await _anchoredAdaptiveAd?.dispose();
    setState(() {
      _anchoredAdaptiveAd = null;
      _isLoaded = false;
    });

    final AnchoredAdaptiveBannerAdSize size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      //print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-2091957797827628/7306344533'
          : 'ca-app-pub-2091957797827628/1127531104',
      size: size,
      request: const AdRequest(nonPersonalizedAds: true),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd.load();
  }

  Widget _getAdWidget() {
    //print('getting ad widget');
    if (_anchoredAdaptiveAd != null && _isLoaded) {
      return Container(
        color: Theme.of(context).backgroundColor,
        width: _anchoredAdaptiveAd.size.width.toDouble(),
        height: _anchoredAdaptiveAd.size.height.toDouble(),
        child: AdWidget(ad: _anchoredAdaptiveAd),
      );
    }
    return Container();
  }

  @override
  initState() {
    getStopData(widget.stop.id);
    checkForInternet();
    getSharedPrefs();
    super.initState();
  }

  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    Prefs prefs = Provider.of<Prefs>(context);
    var primaryColor2 = Theme.of(context).primaryColor;
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: primaryColor2),
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor,
          title: widget.stop.hasCustomName
              ? Text(
                  widget.stop.customName,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              : Text(
                  widget.stop.name.split(', ')[0],
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
          centerTitle: true,
          actions: [
            FavoriteIconButton(stop: widget.stop),
            if (defaultTargetPlatform != TargetPlatform.iOS)
              AndroidPopupMenu(
                stop: widget.stop,
              ),
            if (defaultTargetPlatform == TargetPlatform.iOS)
              IconButton(
                  onPressed: () => showCupertinoModalPopup(
                      context: context,
                      builder: ((context) =>
                          IOSActionSheet(stop: widget.stop))),
                  icon: const Icon(CupertinoIcons.ellipsis))
          ],
        ),
        body: buildBody());
  }

  buildBody() {
    if (!hasConnection) {
      return Stack(
        children: [
          const Center(
            child: Text('No Internet Connection'),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _getAdWidget(),
          )
        ],
      );
    }
    if (_results.isEmpty & !_loading) {
      return Stack(
        children: [
          const Center(
            child: Text('No buses due'),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _getAdWidget(),
          )
        ],
      );
    } else {
      Widget indicator = const CircularProgressIndicator();
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        indicator = const CupertinoActivityIndicator();
      }
      return Stack(children: [
        Center(
            child: _loading
                ? indicator
                : (defaultTargetPlatform == TargetPlatform.iOS)
                    ? CustomScrollView(
                        //padding: const EdgeInsets.fromLTRB(0, 24, 0, 300),
                        slivers: [
                          if (defaultTargetPlatform == TargetPlatform.iOS)
                            CupertinoSliverRefreshControl(
                              onRefresh: () => getStopData(widget.stop.id),
                            ),
                          SliverList(
                              delegate: SliverChildListDelegate([
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                statusMessage,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            ..._results
                          ])),
                        ],
                      )
                    : RefreshIndicator(
                        child: ListView(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                statusMessage,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            ..._results
                          ],
                        ),
                        onRefresh: () => getStopData(widget.stop.id),
                      )),
        Align(
          alignment: Alignment.bottomCenter,
          child: _getAdWidget(),
        )
      ]);
    }
  }

  checkForInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        hasConnection = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        hasConnection = true;
      });
    } else {
      setState(() {
        hasConnection = false;
      });
    }
  }

  Future<void> getStopData(String stopId) async {
    setState(() {
      _results = [];
      _loading = true;
    });

    DateTime now = DateTime.now();

    int year = now.year;
    int month = now.month;
    int day = now.day;

    String monthString = month < 10 ? "0$month" : month.toString();
    try {
      final response = await _client.get(
          'https://journeyplanner.transportforireland.ie/nta/XML_DM_REQUEST?coordOutputFormat=WGS84%5Bdd.ddddd%5D&language=ie&std3_suggestMacro=std3_suggest&std3_commonMacro=dm&includeCompleteStopSeq=1&mergeDep=1&mode=direct&useAllStops=1&type_dm=any&nameInfo_dm=$stopId&itdDateDayMonthYear=$day.$monthString.$year&itdLPxx_snippet=1&itdLPxx_template=dmresults&outputFormat=rapidJSON');

      print(
          'https://journeyplanner.transportforireland.ie/nta/XML_DM_REQUEST?coordOutputFormat=WGS84%5Bdd.ddddd%5D&language=ie&std3_suggestMacro=std3_suggest&std3_commonMacro=dm&includeCompleteStopSeq=1&mergeDep=1&mode=direct&useAllStops=1&type_dm=any&nameInfo_dm=$stopId&itdDateDayMonthYear=$day.$monthString.$year&itdLPxx_snippet=1&itdLPxx_template=dmresults&outputFormat=rapidJSON');
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);

        if (parsed['stopEvents'] == null) {
          setState(() {
            _loading = false;
            _results = [];
          });
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

        lastSynced = DateTime.now();

        setState(() {
          if (lastSynced != null) {
            String hour = lastSynced.hour > 9
                ? lastSynced.hour.toString()
                : '0${lastSynced.hour}';
            String minute = lastSynced.minute > 9
                ? lastSynced.minute.toString()
                : '0${lastSynced.minute}';

            statusMessage = "Last synced $hour:$minute";
          } else if (lastSynced == null) {
            statusMessage = "";
          }
          _results = _results;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          hasConnection = false;
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

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }
}
