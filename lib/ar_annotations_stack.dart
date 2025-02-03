import 'dart:async';
import 'dart:math';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'arcore_geospatial_view.dart';

/// Signature for a function that creates a widget for a given annotation,
typedef AnnotationViewBuilder = Widget Function(
    BuildContext context, ArAnnotation annotation);

typedef ChangeLocationCallback = void Function(ArCameraPose position);

class ArAnnotationsStack extends StatefulWidget {
  const ArAnnotationsStack({
    super.key,
    required this.annotations,
    required this.annotationViewBuilder,
    required this.frame,
    required this.onLocationChange,
    this.annotationWidth = 200,
    this.annotationHeight = 75,
    this.maxVisibleDistance = 1500,
    this.showDebugInfo = true,
    this.paddingOverlap = 5,
    this.yOffsetOverlap,
    required this.minDistanceReload,
    required this.arController,
  });

  final List<ArAnnotation> annotations;
  final AnnotationViewBuilder annotationViewBuilder;
  final double annotationWidth;
  final double annotationHeight;

  final double maxVisibleDistance;

  final Size frame;

  final ChangeLocationCallback onLocationChange;

  final bool showDebugInfo;

  final double paddingOverlap;
  final double? yOffsetOverlap;
  final double minDistanceReload;
  final ARSessionManager? arController;

  @override
  State<ArAnnotationsStack> createState() => _ArAnnotationsStackState();
}

class _ArAnnotationsStackState extends State<ArAnnotationsStack> {
  ArStatus arStatus = ArStatus();
  ArCameraPose? arCameraPose;
  List<double> pitchHistory = [];
  final NativeDeviceOrientationCommunicator _deviceOrientationCommunicator =
      NativeDeviceOrientationCommunicator();
  Stream<NativeDeviceOrientation>? _orientationStream;
  StreamSubscription<NativeDeviceOrientation>? _orientationStreamSubscription;
  NativeDeviceOrientation _orientation = NativeDeviceOrientation.portraitUp;

  @override
  void initState() {
    super.initState();
    _orientationStream =
        _deviceOrientationCommunicator.onOrientationChanged(useSensor: true);
    _orientationStreamSubscription = _orientationStream?.listen((event) {
      _orientation = event;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.arController?.onCameraGeospatialPoseDetected =
          (arcoreGeospatialPose) {
        final newArCameraPose =
            ArCameraPose.fromArcoreGeospatialPose(arcoreGeospatialPose);

        if (arCameraPose == null) {
          widget.onLocationChange(newArCameraPose);
          arCameraPose = newArCameraPose;
        } else {
          final distance = Geolocator.distanceBetween(
            arCameraPose!.latitude,
            arCameraPose!.longitude,
            newArCameraPose.latitude,
            newArCameraPose.longitude,
          );

          // Update latitude and longitude if they significantly changed
          if (distance >= widget.minDistanceReload) {
            // Trigger location change callback if position changed significantly
            widget.onLocationChange(newArCameraPose);
          }
        }

        setState(() {
          // This triggers a UI update with the updated camera pose
          arCameraPose = newArCameraPose;
        });
      };
    });
  }

  @override
  void dispose() {
    _orientationStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    if (arCameraPose != null) {
      _calculateFOV(_orientation, width, height);

      final annotations =
          _filterAndSortArAnnotation(widget.annotations, arCameraPose!);
      _transformAnnotation(annotations);
      return Stack(
        children: [
          if (kDebugMode && widget.showDebugInfo)
            Positioned(
              bottom: 0,
              child: debugInfo(context, arCameraPose),
            ),
          Stack(
              children: annotations.map(
            (e) {
              return Positioned(
                left: e.arPosition.dx,
                top: e.arPosition.dy + height * 0.5,
                child: Transform.translate(
                  offset: Offset(0, e.arPositionOffset.dy),
                  child: SizedBox(
                    width: widget.annotationWidth,
                    child: widget.annotationViewBuilder(context, e),
                  ),
                ),
              );
            },
          ).toList()),
        ],
      );
    } else {
      return loading();
    }
  }

  Widget debugInfo(BuildContext context, ArCameraPose? arCameraPose) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude          : ${arCameraPose?.latitude}'),
            Text('Longitude         : ${arCameraPose?.longitude}'),
            Text('heading           : ${arCameraPose?.heading}'),
            Text('pitch             : ${arCameraPose?.pitch}'),
            Text('roll              : ${arCameraPose?.roll}'),
            Text('Device orientation: $_orientation'),
            Text('Altitude           : ${arCameraPose?.altitude}'),
          ],
        ),
      ),
    );
  }

  Widget loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _calculateFOV(
      NativeDeviceOrientation? orientation, double width, double height) {
    double hFov = 0;
    double vFov = 0;
    const tempFOv = 58.0;

    if (orientation == NativeDeviceOrientation.landscapeLeft ||
        orientation == NativeDeviceOrientation.landscapeRight) {
      hFov = tempFOv;
      vFov = (2 * atan(tan((hFov / 2).toRadians) * (height / width))).toDegrees;
    } else {
      vFov = tempFOv;
      hFov = (2 * atan(tan((vFov / 2).toRadians) * (width / height))).toDegrees;
    }
    arStatus.hFov = hFov;
    arStatus.vFov = vFov;
    arStatus.hPixelPerDegree = hFov > 0 ? (width / hFov) : 0;
    arStatus.vPixelPerDegree = vFov > 0 ? (height / vFov) : 0;
  }

  List<ArAnnotation> _visibleAnnotations(
      List<ArAnnotation> annotations, double heading) {
    final degreesDeltaH = arStatus.hFov;
    return annotations.where((ArAnnotation annotation) {
      final delta = ArMath.deltaAngle(heading, annotation.azimuth);
      final isVisible = delta.abs() < degreesDeltaH;
      annotation.isVisible = isVisible;
      return annotation.isVisible;
    }).toList();
  }

  List<ArAnnotation> _calculateDistanceAndBearingFromUser(
      List<ArAnnotation> annotations, ArCameraPose arCameraPose) {
    return annotations.map((e) {
      final annotationLocation = e.position;
      e.azimuth = Geolocator.bearingBetween(
        arCameraPose.latitude,
        arCameraPose.longitude,
        annotationLocation.latitude,
        annotationLocation.longitude,
      );

      e.distanceFromUser = Geolocator.distanceBetween(
          arCameraPose.latitude,
          arCameraPose.longitude,
          annotationLocation.latitude,
          annotationLocation.longitude);
      e.elevationAngle = ArMath.elevationAngle(arCameraPose.altitude,
          annotationLocation.altitude, e.distanceFromUser);

      final dy = arCameraPose.pitch * arStatus.vPixelPerDegree - e.elevationAngle * arStatus.vPixelPerDegree;
      final dx = ArMath.deltaAngle(e.azimuth, arCameraPose.heading) *
          arStatus.hPixelPerDegree;
      e.arPosition = Offset(dx, dy);
      return e;
    }).toList();
  }

  List<ArAnnotation> _filterAndSortArAnnotation(
      List<ArAnnotation> annotations, ArCameraPose arCameraPose) {
    List<ArAnnotation> temps =
        _calculateDistanceAndBearingFromUser(annotations, arCameraPose);
    temps = annotations
        .where(
            (element) => element.distanceFromUser < widget.maxVisibleDistance)
        .toList();
    temps = _visibleAnnotations(temps, arCameraPose.heading);
    return temps;
  }

  void _transformAnnotation(List<ArAnnotation> annotations) {
    annotations.sort((a, b) => (a.distanceFromUser < b.distanceFromUser)
        ? -1
        : ((a.distanceFromUser > b.distanceFromUser) ? 1 : 0));
  }
}
