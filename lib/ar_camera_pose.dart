import 'package:ar_flutter_plugin/models/ar_geospatial_pose.dart';
import 'package:arcore_geospatial_view/arcore_geospatial_view.dart';
import 'package:arcore_geospatial_view/euler_angles.dart';
import 'package:vector_math/vector_math_64.dart';

class ArCameraPose {
  final double heading;
  final double pitch;
  final double roll;
  final double latitude;
  final double longitude;
  final double altitude;

  const ArCameraPose(
      {required this.latitude,
      required this.longitude,
      required this.altitude,
      required this.heading,
      required this.pitch,
      required this.roll});

  /// CopyWith method for creating a modified copy of the instance
  ArCameraPose copyWith({
    double? heading,
    double? pitch,
    double? roll,
    double? latitude,
    double? longitude,
    double? altitude,
  }) {
    return ArCameraPose(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        heading: heading ?? this.heading,
        pitch: pitch ?? this.pitch,
        roll: roll ?? this.roll,
        altitude: altitude ?? this.altitude);
  }

  @override
  String toString() {
    return 'ArCameraPose(latitude: $latitude, longitude: $longitude, altitude: $altitude, heading: $heading, pitch: $pitch)';
  }

  factory ArCameraPose.fromArcoreGeospatialPose(ARGeospatialPose arcoreGeospatialPose) {
    final x = arcoreGeospatialPose.eastUpSouthQuaternion?[0] ?? 0;
    final y = arcoreGeospatialPose.eastUpSouthQuaternion?[1] ?? 0;
    final z = arcoreGeospatialPose.eastUpSouthQuaternion?[2] ?? 0;
    final w = arcoreGeospatialPose.eastUpSouthQuaternion?[3] ?? 0;

    final newX = -z;
    final newY = x;
    final newZ = -y;
    final quaternion = Quaternion(newX, newY, newZ, w);

    final angles = EulerAngles.fromQuaternion(quaternion);
    final heading = angles.yaw.toDegrees;
    final pitch = angles.pitch.toDegrees;

    return ArCameraPose(
        latitude: arcoreGeospatialPose.latitude ?? 0,
        longitude: arcoreGeospatialPose.longitude ?? 0,
        altitude: arcoreGeospatialPose.altitude ?? 0,
        heading: heading,
        pitch: pitch,
        roll: angles.roll.toDegrees);
  }
}
