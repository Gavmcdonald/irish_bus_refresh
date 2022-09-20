import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/providers/stop_list_provider.dart';
import 'package:provider/provider.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({Key key}) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final searchBoxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CupertinoSearchTextField(
          controller: searchBoxController,
          onChanged: (entered) => Provider.of<StopList>(context, listen: false)
              .filterStopList(entered),
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: searchBoxController,
        onChanged: (entered) => Provider.of<StopList>(context, listen: false)
            .filterStopList(entered),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          hintText: 'Enter Stop Name or Number',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}
