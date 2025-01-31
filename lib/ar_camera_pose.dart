import 'package:arcore_geospatial_view/arcore_geospatial_view.dart';
import 'package:arcore_geospatial_view/euler_angles.dart';
import 'package:vector_math/vector_math_64.dart';

class ArCameraPose {
  final double heading;
  final double pitch;
  final double roll;
  final double latitude;
  final double longitude;

  const ArCameraPose(
      {required this.latitude,
      required this.longitude,
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
  }) {
    return ArCameraPose(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        heading: heading ?? this.heading,
        pitch: pitch ?? this.pitch,
        roll: roll ?? this.roll);
  }

  @override
  String toString() {
    return 'ArCameraPose(latitude: $latitude, longitude: $longitude, heading: $heading, pitch: $pitch)';
  }

  factory ArCameraPose.fromArcoreGeospatialPose(arcoreGeospatialPose) {
    final x = arcoreGeospatialPose.eastUpSouthQuaternion[0];
    final y = arcoreGeospatialPose.eastUpSouthQuaternion[1];
    final z = arcoreGeospatialPose.eastUpSouthQuaternion[2];
    final w = arcoreGeospatialPose.eastUpSouthQuaternion[3];

    final newX = -z;
    final newY = x;
    final newZ = -y;
    final quaternion = Quaternion(newX, newY, newZ, w);

    final angles = EulerAngles.fromQuaternion(quaternion);
    final heading = angles.yaw.toDegrees;
    final pitch = angles.pitch.toDegrees;

    return ArCameraPose(
        latitude: arcoreGeospatialPose.latitude,
        longitude: arcoreGeospatialPose.longitude,
        heading: heading,
        pitch: pitch,
        roll: angles.roll.toDegrees);
  }
}
