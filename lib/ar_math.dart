import 'dart:math';

import 'package:arcore_geospatial_view/ar_extension.dart';
import 'package:geolocator/geolocator.dart';

class ArMath {

  static double deltaAngle(double angle1, double angle2) {
    var deltaAngle = angle1 - angle2;
    if (deltaAngle > 180) {
      deltaAngle -= 360;
    } else if (deltaAngle < -180) {
      deltaAngle += 360;
    }
    return deltaAngle;
  }

  static double bearingBetween(Position startLocation, Position endLocation) {
    double bearing = 0;
    final double lat1 = startLocation.latitude.toRadians;
    final double lon1 = startLocation.longitude.toRadians;

    final double lat2 = endLocation.latitude.toRadians;
    final double lon2 = endLocation.longitude.toRadians;

    final double dLon = lon2 - lon1;
    final double y = sin(dLon) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final double radiansBearing = atan2(y, x);
    bearing = radiansBearing.toDegrees;
    if (bearing < 0) {
      bearing += 360;
    }

    return bearing;
  }
}
