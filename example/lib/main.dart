import 'package:arcore_geospatial_view/ar_camera_pose.dart';
import 'package:arcore_geospatial_view_example/annotation_view.dart';
import 'package:arcore_geospatial_view_example/annotations.dart';
import 'package:flutter/material.dart';
import 'package:arcore_geospatial_view/arcore_geospatial_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Annotation> annotations = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ArcoreGeospatialWidget(
          annotations: annotations,
          showDebugInfo: true,
          annotationViewBuilder: (context, annotation) {
            return AnnotationView(
              key: ValueKey(annotation.uid),
              annotation: annotation as Annotation,
            );
          },
          onLocationChange: (ArCameraPose position) {
            Future.delayed(const Duration(seconds: 5), () {
              annotations =
                  fakeAnnotation(position: position, numberMaxPoi: 50);
              setState(() {});
            });
          },
        ),
      ),
    );
  }
}
