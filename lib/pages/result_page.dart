import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:irish_bus_refresh/widgets/result_list.dart';
import 'package:irish_bus_refresh/widgets/android_popup_menu.dart';
import 'package:irish_bus_refresh/widgets/ios_action_sheet.dart';
import 'package:provider/provider.dart';
import '../widgets/favorite_icon_button.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key key, @required this.stop}) : super(key: key);
  final Stop stop;

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  BannerAd _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoaded == false) {
      _loadAd();
    }
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
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd.load();
  }

  Widget _getAdWidget() {
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
  Widget build(BuildContext context) {
    // ignore: unused_local_variable - triggers rebuild when prefs changes, unused_local_variable
    Prefs prefs = Provider.of<Prefs>(context);
    var primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: primaryColor),
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor,
          title: widget.stop.hasCustomName
              ? Text(
                  widget.stop.customName,
                  style: TextStyle(color: primaryColor),
                )
              : Text(
                  widget.stop.name.split(', ')[0],
                  style: TextStyle(color: primaryColor),
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
        body: ResultList(stop: widget.stop, adWidget: _getAdWidget()));
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }
}
