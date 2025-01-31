import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

class EulerAngles {
  final double roll;
  final double pitch;
  final double yaw;

  EulerAngles({required this.roll, required this.pitch, required this.yaw});

  factory EulerAngles.fromQuaternion(Quaternion q) {
    late final double yaw;
    late final double pitch;
    late final double roll;

    // roll (x-axis rotation)
    final double sinrCosp = 2 * (q.w * q.x + q.y * q.z);
    final double cosrCosp = 1 - 2 * (q.x * q.x + q.y * q.y);
    roll = atan2(sinrCosp, cosrCosp);

    // pitch (y-axis rotation)
    final double sinp = sqrt(1 + 2 * (q.w * q.y - q.x * q.z));
    final double cosp = sqrt(1 - 2 * (q.w * q.y - q.x * q.z));
    pitch = 2 * atan2(sinp, cosp) - pi / 2;

    // yaw (z-axis rotation)
    final double sinyCosp = 2 * (q.w * q.z + q.x * q.y);
    final double cosyCosp = 1 - 2 * (q.y * q.y + q.z * q.z);
    yaw = atan2(sinyCosp, cosyCosp);

    return EulerAngles(roll: roll, pitch: pitch, yaw: yaw);
  }
}
