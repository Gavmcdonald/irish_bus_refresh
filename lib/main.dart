import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:irish_bus_refresh/pages/favourite_page.dart';
import 'package:irish_bus_refresh/pages/map_page.dart';
import 'package:irish_bus_refresh/pages/search_page.dart';
import 'package:irish_bus_refresh/pages/settings_page.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  runApp(ChangeNotifierProvider.value(value: Prefs(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: <NavigatorObserver>[observer],
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
    MapSample(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    getReview();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, optionSelection),
      bottomNavigationBar: getNavBar(_selectedIndex, _onItemTapped, context),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  void optionSelection(String selection) {
    if (selection == "Settings") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsPage()));
    }
  }
}

getReview() async {
    final InAppReview inAppReview = InAppReview.instance;

    final prefs = await SharedPreferences.getInstance();

    final bool askedForReview = prefs.getBool('askedForReview');

    if (askedForReview == null) {
      await prefs.setBool('askedForReview', false);
    }

    if (askedForReview == false) {
      final int timesOpened = prefs.getInt('timesOpened');

      if (timesOpened == null) {
        await prefs.setInt('timesOpened', 1);
      }

      if (timesOpened != null) {
        if (timesOpened == 30) {
          if (await inAppReview.isAvailable()) {
            inAppReview.requestReview();
          }

          await prefs.setBool('askedForReview', true);
        } else {
          await prefs.setInt('timesOpened', timesOpened + 1);
        }
      }
    }
  }

getAppBar(context, optionSelection) {


  if(defaultTargetPlatform == TargetPlatform.iOS){
    return AppBar(
      toolbarHeight: 0,
      toolbarOpacity: 0,
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 0,
    );
  }

  return AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark),
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        actions:  [
          if(defaultTargetPlatform != TargetPlatform.iOS)
          IconButton(
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MapSample()));
            },
            icon: const Icon(Icons.location_pin),
            color: Theme.of(context).colorScheme.primary,
          ),
          if(defaultTargetPlatform != TargetPlatform.iOS)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.adaptive.more,
              color: Theme.of(context).primaryColor
            ),
            onSelected: optionSelection,
            itemBuilder: (BuildContext context) {
              List<String> options = ["Settings"];
              return options.map((String option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
          )
        ],
      );
}

getNavBar(_selectedIndex, _onItemTapped, context) {

  if(defaultTargetPlatform !=  TargetPlatform.iOS){
    return CupertinoTabBar(
       //activeColor: Theme.of(context).primaryColor,
       items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_border_outlined), label: 'favourites')
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
    );
  }

  else { 

    return CupertinoTabBar(
      border: const Border(),
      iconSize: 24.0,
      //inactiveColor: Theme.of(context).primaryColor,
        items:  const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.star), label: 'Favourites'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      );
  }

}
