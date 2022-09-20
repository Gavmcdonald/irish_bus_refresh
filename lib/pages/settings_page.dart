//import 'package:app_review/app_review.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:irish_bus_refresh/widgets/theme_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:package_info/package_info.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool showScheduledDepartures = false;
  String version;
  String buildNumber;

  @override
  void initState() {
    getSharedPrefs();
    getPackageInfo();
    super.initState();
  }

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showScheduledDepartures =
        (prefs.getBool('showScheduledDepartures') ?? false);
    setState(() {});
  }

  getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  //
  toggleShowScheduledDepartures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('showScheduledDepartures', !showScheduledDepartures);
    setState(() {
      showScheduledDepartures = !showScheduledDepartures;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Padding(
        padding: getPadding(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: ListTile(
                title: const Text("Show Scheduled Departures"),
                subtitle: const Text(
                    "Scheduled departures have no real time data and therefore may be more unreliable. "
                    "We filter these out by default to improve reliability."),
                isThreeLine: true,
                trailing: getCheckBox(),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text("About App"),
              subtitle: Text("Version: $version\nBuild Number: $buildNumber"),
              isThreeLine: true,
            ),
            const Divider(),
            ListTile(
                title: const Text("Privacy Policy"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          settings: const RouteSettings(name: "Privacy Policy"),
                          builder: (context) => const PrivacyPolicy()));
                }),
                const Divider(),
            ListTile(title: const Text("Theme"), subtitle: ThemeSwitcher()),
            const Divider()
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: const Text("Settings"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: ListTile(
              title: const Text("Show Scheduled Departures"),
              subtitle: const Text(
                  "Scheduled departures have no real time data and therefore may be more unreliable. "
                  "We filter these out by default to improve reliability."),
              isThreeLine: true,
              trailing: getCheckBox(),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("About App"),
            subtitle: Text("Version: $version\nBuild Number: $buildNumber"),
            isThreeLine: true,
          ),
          const Divider(),
          ListTile(
              title: const Text("Privacy Policy"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        settings: const RouteSettings(name: "Privacy Policy"),
                        builder: (context) => const PrivacyPolicy()));
              })
        ],
      ),
    );
  }

  Widget getCheckBox() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoSwitch(
          value: showScheduledDepartures,
          onChanged: (boo) => toggleShowScheduledDepartures());
    } else {
      return Checkbox(
          value: showScheduledDepartures,
          onChanged: (boo) {
            toggleShowScheduledDepartures();
          });
    }
  }

  getPadding() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const EdgeInsets.only(top: 32);
    }

    return const EdgeInsets.fromLTRB(0, 0, 0, 0);
  }
}

class PrivacyPolicy extends StatelessWidget {
  final String _markdownData = """## Privacy Policy

  Gavin McDonald built the Irish Bus Real Time app as a Free app. This SERVICE is provided by Gavin McDonald at no cost and is intended for use as is.

  This page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.

  If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.

  The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Irish Bus Real Time unless otherwise defined in this Privacy Policy.

  **Information Collection and Use**

  For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information. The information that I request will be retained on your device and is not collected by me in any way.

  The app does use third party services that may collect information used to identify you.

  Link to privacy policy of third party service providers used by the app

  *   [Google Play Services](https://www.google.com/policies/privacy/)
  *   [AdMob](https://support.google.com/admob/answer/6128543?hl=en)
  *   [Firebase Analytics](https://firebase.google.com/policies/analytics)

  **Log Data**

  I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.

  **Cookies**

  Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.

  This Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.

  **Service Providers**

  I may employ third-party companies and individuals due to the following reasons:

  *   To facilitate our Service;
  *   To provide the Service on our behalf;
  *   To perform Service-related services; or
  *   To assist us in analyzing how our Service is used.

  I want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.

  **Security**

  I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security.

  **Links to Other Sites**

  This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. Therefore, I strongly advise you to review the Privacy Policy of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.

  **Children’s Privacy**

  These Services do not address anyone under the age of 13\. I do not knowingly collect personally identifiable information from children under 13\. In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that I will be able to do necessary actions.

  **Changes to This Privacy Policy**

  I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.

  **Contact Us**

  If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me.
  """;

  const PrivacyPolicy({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).canvasColor),
        elevation: 0.0,
      ),
      body: Markdown(
        data: _markdownData,
      ),
    );
  }
}
