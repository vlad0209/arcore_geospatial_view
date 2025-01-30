import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

class EulerAngles {
  final double roll;
  final double pitch;
  final double yaw;

  EulerAngles({required this.roll, required this.pitch, required this.yaw});

  factory EulerAngles.fromQuaternion(Quaternion q1) {
    late final double yaw;
    late final double pitch;
    late final double roll;

    final sqx = q1.x * q1.x;
    final sqy = q1.y * q1.y;
    final sqz = q1.z * q1.z;

    yaw = -atan2(2 * q1.y * q1.w - 2 * q1.x * q1.z, 1 - 2 * sqy - 2 * sqz);
    pitch = atan2(2 * q1.x * q1.w - 2 * q1.y * q1.z, 1 - 2 * sqx - 2 * sqz);
    roll = -asin(2 * q1.x * q1.y + q1.z * q1.w);

    return EulerAngles(roll: roll, pitch: pitch, yaw: yaw);
  }
}
