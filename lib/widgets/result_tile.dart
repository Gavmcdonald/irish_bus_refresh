import 'package:flutter/material.dart';

class ResultTile extends StatelessWidget {
  const ResultTile({@required this.route, @required this.destination, @required this.departureTime });

  final String route;
  final String destination;
  final String departureTime;

  
  @override
  Widget build(BuildContext context) {

    final _biggerFont = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.primary);
    return Column(
      children: <Widget>[
        ListTile(
          leading: Text(route, style: _biggerFont,),
          title: Text(destination, style: _biggerFont,),
          trailing: departureTime == "Due"
              ? Text("Due", style: _biggerFont,)
              : Text("$departureTime", style: _biggerFont,),
        ),
        Divider(indent: 16.0,endIndent: 16.0,),
      ],
    );
    ;
  }
}
