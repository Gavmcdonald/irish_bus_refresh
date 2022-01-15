import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:irish_bus_refresh/pages/favourite_page.dart';
import 'package:irish_bus_refresh/pages/map_page.dart';
import 'package:irish_bus_refresh/pages/search_page.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:provider/provider.dart';

void main() {

  if (defaultTargetPlatform == TargetPlatform.android) {
  AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
}
  runApp(ChangeNotifierProvider.value(
    value: Prefs(),
    child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, @required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  static const List<Widget> _widgetOptions = <Widget>[
    SearchPage(),
    FavouritesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MapSample(
                          )));
          }, icon: const Icon(Icons.location_pin), color: Theme.of(context).colorScheme.primary,)
        ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_border_outlined), label: 'favourites')
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}
