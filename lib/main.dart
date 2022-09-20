import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:irish_bus_refresh/providers/network_provider.dart';
import 'package:irish_bus_refresh/providers/theme_provider.dart';
import 'package:irish_bus_refresh/services/prefs.dart';
import 'package:irish_bus_refresh/widgets/theme_switcher.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_home_page.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ThemeMode initialTheme;

      SharedPreferences prefs = await SharedPreferences.getInstance();

    String data = prefs.getString("savedTheme");
    print(data);

    if (data != null) {
      if (data == "Light") {
       initialTheme = appThemes[0].mode;
      }
      if (data == "Dark") {
        initialTheme =  appThemes[1].mode;
        print("inital theme dark");
      }
      if (data == "Auto") {
        initialTheme = appThemes[2].mode;
      }
    }

  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  //Rprint(initialTheme.toString());
  runApp(ChangeNotifierProvider.value(value: Prefs(), child: MyApp(initialTheme: initialTheme)));


  
}

class MyApp extends StatelessWidget {
  final ThemeMode initialTheme;

  const MyApp({Key key, this.initialTheme}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => Network())),
        ChangeNotifierProvider(create: ((context) => ThemeProvider(initialTheme))),
      ],
      child: Consumer<ThemeProvider>(
        child: const AppHomePage(),
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorObservers: <NavigatorObserver>[observer],
            title: 'Irish Bus Real Time',
            themeMode: themeProvider.selectedThemeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              //primaryColor: themeProvider.selectedPrimaryColor,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.lightBlue,
              //primaryColor: themeProvider.selectedPrimaryColor,
            ),
            home: child,
          );
        },
      ),
    );
  }
}
