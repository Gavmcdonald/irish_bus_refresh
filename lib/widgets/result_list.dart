import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/providers/network_provider.dart';
import 'package:provider/provider.dart';

import '../models/stop.dart';

class ResultList extends StatefulWidget {
  const ResultList({Key key, this.stop, this.adWidget}) : super(key: key);

  final Stop stop;
  final Widget adWidget;

  @override
  State<ResultList> createState() => _ResultListState();
}

class _ResultListState extends State<ResultList> {
  @override
  Widget build(BuildContext context) {
    Network network = Provider.of<Network>(context);
    if (network.hasConnection) {
      return Stack(
        children: [
          const Center(
            child: Text('No Internet Connection'),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: widget.adWidget,
          )
        ],
      );
    }
    if (network.stopResults.isEmpty & !network.isLoading) {
      return Stack(
        children: [
          const Center(
            child: Text('No buses due'),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: widget.adWidget,
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
            child: network.isLoading
                ? indicator
                : (defaultTargetPlatform == TargetPlatform.iOS)
                    ? CustomScrollView(
                        //padding: const EdgeInsets.fromLTRB(0, 24, 0, 300),
                        slivers: [
                          if (defaultTargetPlatform == TargetPlatform.iOS)
                            CupertinoSliverRefreshControl(
                              onRefresh: () =>
                                  network.getStopData(widget.stop.id),
                            ),
                          SliverList(
                              delegate: SliverChildListDelegate([
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                network.statusMessage,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            ...network.stopResults
                          ])),
                        ],
                      )
                    : RefreshIndicator(
                        child: ListView(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                network.statusMessage,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            ...network.stopResults
                          ],
                        ),
                        onRefresh: () => network.getStopData(widget.stop.id),
                      )),
        Align(
          alignment: Alignment.bottomCenter,
          child: widget.adWidget,
        )
      ]);
    }
  }
}
