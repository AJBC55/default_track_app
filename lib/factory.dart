import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

// this File should contain all of the track specific information there should be no track specific informaton in any other file other than here or a media file
// !!!All app specific data should be passed to each part of the app
// Ex: events timing through dependancy injection!!!
const String geteventsUrl =
    "https://css-container-ztob2eeuta-uc.a.run.app/consumer/events/irwindale";
const String userUrl =
    "https://css-backend-v1-92fa8dcd9de6.herokuapp.com/irwindale/users";
const String loginUrl =
    "https://css-backend-v1-92fa8dcd9de6.herokuapp.com/irwindale/login";
const String getNewsUrl =
    "https://css-container-ztob2eeuta-uc.a.run.app/consumer/news/irwindale";
const String getTimingURl =
    "https://css-container-ztob2eeuta-uc.a.run.app/timing/subscribe/irwindale";

final Image logo = Image.asset(
  'assets/logo.png',
  height: 50,
);

const initialCameraPosition = CameraPosition(
  target: LatLng(34.109298, -117.986247),
  zoom: 16.7,
  tilt: 40.0,
  bearing: 294.0,
);

String jsonLocation = 'assets/irwindalelocations.json';
