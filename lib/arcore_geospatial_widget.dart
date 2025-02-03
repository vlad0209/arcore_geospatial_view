import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
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
    this.showDebugInfo = false,
    this.iosApiKey
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

  //Google Cloud API key required for iOS only
  final String? iosApiKey;

  @override
  State<ArcoreGeospatialWidget> createState() => _ArcoreGeospatialWidgetState();
}

class _ArcoreGeospatialWidgetState extends State<ArcoreGeospatialWidget> {
  bool initCam = false;
  ARSessionManager? _arController;

  @override
  void dispose() {
    _arController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ARView(onARViewCreated:(arSessionManager, arObjectManager, arAnchorManager, arLocationManager) {
          setState(() {
            initCam = true;
            _arController = arSessionManager;
            _arController!.onInitialize(showPlanes: false, showAnimatedGuide: false);
            _arController!.enableGeospatialMode(iosApiKey: widget.iosApiKey);
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
            arController: _arController,
          ),
        if (widget.accessory != null) widget.accessory!
      ],
    );
  }
}
