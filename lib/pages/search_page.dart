import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/widgets/search_box.dart';
import 'package:irish_bus_refresh/widgets/stop_tile.dart';
import 'package:provider/provider.dart';

import '../providers/stop_list_provider.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({Key key}) : super(key: key);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  EdgeInsetsGeometry searchBoxPadding =
      (defaultTargetPlatform == TargetPlatform.iOS)
          ? const EdgeInsets.only(top: 36)
          : const EdgeInsets.fromLTRB(0, 0, 0, 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: searchBoxPadding,
      child: (Column(
        children: <Widget>[
          SearchBox(),
          Flexible(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                for (Stop stop
                    in Provider.of<StopList>(context).filteredStopList)
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
}
