import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:irish_bus_refresh/assets/route_data.dart';
import 'package:irish_bus_refresh/models/stop.dart';
import 'package:irish_bus_refresh/pages/result_page.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();

  List<Marker> _allMarkers = [];
  List<Marker> _filteredMarkers = [];
  double _searchRadius = 5.0;

  @override
  initState() {
    List<Marker> allMarkers = [];

    String data = routeData;
    var parsed = json.decode(data);

    for (var data in parsed) {
      Stop stop = Stop.fromJson(data);
      allMarkers.add(Marker(
        infoWindow: InfoWindow(
            title: stop.name.split(", ")[0],
            snippet: stop.stopNumber,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResultPage(
                            stop: stop,
                            key: ValueKey(stop),
                          )));
            }),
        markerId: MarkerId(stop.stopNumber),
        position: LatLng(stop.lat, stop.long),
      ));

      //   Marker(
      //       markerId: MarkerId(stop.stopNumber),
      //       position: LatLng(stop.lat, stop.long)),
      // );
    }

    _allMarkers = allMarkers;
    getNearbyStops(_ireland.target);
    super.initState();
  }

  LatLng cameraPosition = _ireland.target;

  static const CameraPosition _ireland = CameraPosition(
    target: LatLng(53.07316879898958, -7.132904045283795),
    zoom: 12,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {

    _determinePosition();
    print('number of filtered markers${_filteredMarkers.length}');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Map Vew'),
        centerTitle: true,

      ),
      body: GoogleMap(
        minMaxZoomPreference: const MinMaxZoomPreference(13.0, 20.0),
        myLocationButtonEnabled: true,
        markers: _filteredMarkers.toSet(),
        onCameraMove: (position) {
          cameraPosition = position.target;
        },
        onCameraIdle: () {
          getNearbyStops(cameraPosition);
        },
        indoorViewEnabled: false,
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        compassEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: _ireland,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    controller.getVisibleRegion();
  }

  filterMarkers(LatLng cameraPosition) {
    print(cameraPosition.toString());
  }

  getNearbyStops(LatLng cameraPosition) {
    double searchRadius = 3.0;

    const double pi = 3.1415926535897932;

    List<Marker> markers = [];
    _allMarkers.forEach((stop) {
      if (cameraPosition.latitude != null) {
        var stoplong = stop.position.longitude;
        var stoplat = stop.position.latitude;

        double distance = (6371.0 *
            acos(cos(toRadians(stoplat)) *
                    cos(toRadians(cameraPosition.latitude)) *
                    cos(toRadians(cameraPosition.longitude) -
                        toRadians(stoplong)) +
                sin(toRadians(stoplat)) *
                    sin(toRadians(cameraPosition.latitude))));

        if (distance < searchRadius) {
          markers.add(stop);
        }
      }
    });

    setState(() {
      _filteredMarkers = markers;
    });
  }

  double toRadians(double num) {
    return ((num * pi) / 180);
  }

  Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
}
