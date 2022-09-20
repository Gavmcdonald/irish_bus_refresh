import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  StopList stopList;

  @override
  void didChangeDependencies() {
    stopList = Provider.of<StopList>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: searchBoxPadding,
      child: (Column(
        children: <Widget>[
          const SearchBox(),
          Flexible(
            child: ListView.builder(
              itemCount: stopList.filteredStopList.length,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              prototypeItem: StopTile(
                    stop: stopList.filteredStopList.first,
                    key: ValueKey(stopList.filteredStopList.first),
                  ),
              itemBuilder: ((context, index) {
                return StopTile(
                    stop: stopList.filteredStopList[index],
                    key: ValueKey(stopList.filteredStopList[index]),
                  );
              }),
            ),
          ),
        ],
      )),
    );
  }
}
