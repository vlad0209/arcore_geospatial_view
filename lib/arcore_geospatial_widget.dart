import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';

import 'arcore_geospatial_view.dart';

class ArcoreGeospatialWidget extends StatefulWidget {
  const ArcoreGeospatialWidget({
    super.key,
    required this.annotations,
    required this.annotationViewBuilder,
    required this.onLocationChange,
    this.annotationWidth = 200,
    this.annotationHeight = 75,
    this.maxVisibleDistance = 1500,
    this.frame,
    this.paddingOverlap = 5,
    this.yOffsetOverlap,
    this.accessory,
    this.minDistanceReload = 50,
    this.showDebugInfo = false
  });

  ///List of POIs
  final List<ArAnnotation> annotations;

  ///Function given context and annotation
  ///return widget for annotation view
  final AnnotationViewBuilder annotationViewBuilder;

  ///Annotation view width
  final double annotationWidth;

  ///Annotation view height
  final double annotationHeight;

  ///Max distance marker visible
  final double maxVisibleDistance;

  final Size? frame;

  ///Callback when location change
  final ChangeLocationCallback onLocationChange;

  ///Padding when marker overlap
  final double paddingOverlap;

  ///Offset overlap y
  final double? yOffsetOverlap;

  ///accessory
  final Widget? accessory;

  ///Min distance reload
  final double minDistanceReload;

  final bool showDebugInfo;

  @override
  State<ArcoreGeospatialWidget> createState() => _ArcoreGeospatialWidgetState();
}

class _ArcoreGeospatialWidgetState extends State<ArcoreGeospatialWidget> {
  bool initCam = false;
  ArCoreController? _arCoreController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ArCoreView(
          enableUpdateListener: true,
          enableGeospatialMode: true,
          enablePlaneRenderer: false,
          onArCoreViewCreated:(controller) {
          setState(() {
            initCam = true;
            _arCoreController = controller;
          });
        },),
        if (initCam)
          ArAnnotationsStack(
            showDebugInfo: widget.showDebugInfo,
            annotations: widget.annotations,
            annotationViewBuilder: widget.annotationViewBuilder,
            frame: widget.frame ??
                const Size(
                  100,
                  75,
                ),
            onLocationChange: widget.onLocationChange,
            annotationWidth: widget.annotationWidth,
            annotationHeight: widget.annotationHeight,
            maxVisibleDistance: widget.maxVisibleDistance,
            paddingOverlap: widget.paddingOverlap,
            yOffsetOverlap: widget.yOffsetOverlap,
            minDistanceReload: widget.minDistanceReload,
            arCoreController: _arCoreController,
          ),
        if (widget.accessory != null) widget.accessory!
      ],
    );
  }
}
