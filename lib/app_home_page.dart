import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:irish_bus_refresh/pages/favourite_page.dart';
import 'package:irish_bus_refresh/pages/map_page.dart';
import 'package:irish_bus_refresh/pages/search_page.dart';
import 'package:irish_bus_refresh/pages/settings_page.dart';
import 'package:irish_bus_refresh/widgets/main_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHomePage extends StatefulWidget {
  const AppHomePage({Key key}) : super(key: key);

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  int _selectedTab = 1;

  static const List<Widget> _tabOptions = <Widget>[
    SearchPage(),
    FavouritesPage(),
    MapSample(),
    SettingsPage(),
  ];

  void _onTabTapped(int tabPosition) {
    setState(() {
      _selectedTab = tabPosition;
    });
  }

  @override
  void initState() {
    promptUserForReview();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      bottomNavigationBar: getNavBar(_selectedTab, _onTabTapped, context),
      body: Center(
        child: _tabOptions.elementAt(_selectedTab),
      ),
    );
  }
}

getNavBar(_selectedIndex, _onItemTapped, context) {
  bool isiOS = (defaultTargetPlatform == TargetPlatform.iOS);
  Icon searchIcon =
      isiOS ? const Icon(CupertinoIcons.search) : const Icon(Icons.search);
  Icon favoriteIcon = isiOS
      ? const Icon(CupertinoIcons.star)
      : const Icon(Icons.star_border_outlined);

  return CupertinoTabBar(
    border: const Border(),
    iconSize: 28,
    items: [
      BottomNavigationBarItem(icon: searchIcon, label: 'Search'),
      BottomNavigationBarItem(icon: favoriteIcon, label: 'favourites'),
      if (isiOS) ...[
        const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map), label: 'Map'),
        const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings), label: 'Settings'),
      ]
    ],
    currentIndex: _selectedIndex,
    onTap: _onItemTapped,
  );
}

promptUserForReview() async {
  final InAppReview inAppReview = InAppReview.instance;
  final devicePreferences = await SharedPreferences.getInstance();
  final bool askedForReview = devicePreferences.getBool('askedForReview');

  if (askedForReview == null) {
    await devicePreferences.setBool('askedForReview', false);
  }

  if (askedForReview == false) {
    final int timesOpened = devicePreferences.getInt('timesOpened');

    if (timesOpened == null) {
      await devicePreferences.setInt('timesOpened', 1);
    }

    if (timesOpened != null) {
      const int appOpensBeforePrompt = 10;
      if (timesOpened == appOpensBeforePrompt) {
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        }
        await devicePreferences.setBool('askedForReview', true);
      } else {
        await devicePreferences.setInt('timesOpened', timesOpened + 1);
      }
    }
  }
}
