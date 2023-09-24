import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

int lastId = 0;

double priorityVeryHigh = 14.5;
double priorityHigh = 15;
double priorityMedium = 16;
double priorityLow = 16.5;
double priorityVeryLow = 17.5;

class PriorityMarker {
  final Key? key;

  /// Coordinates of the marker
  final LatLng point;

  /// Function that builds UI of the marker
  final WidgetBuilder builder;

  /// Bounding box width of the marker
  final double width;

  /// Bounding box height of the marker
  final double height;

  /// Positioning of the [builder] widget relative to the center of its bounding
  /// box defined by its [height] & [width]
  final AnchorPos? anchorPos;

  /// Whether to counter rotate markers to the map's rotation, to keep a fixed
  /// orientation
  final bool? rotate;

  /// The origin of the coordinate system (relative to the upper left corner of
  /// this render object) in which to apply the matrix.
  ///
  /// Setting an origin is equivalent to conjugating the transform matrix by a
  /// translation. This property is provided just for convenience.
  final Offset? rotateOrigin;

  /// The alignment of the origin, relative to the size of the box.
  ///
  /// This is equivalent to setting an origin based on the size of the box.
  /// If it is specified at the same time as the [rotateOrigin], both are applied.
  ///
  /// An [AlignmentDirectional.centerStart] value is the same as an [Alignment]
  /// whose [Alignment.x] value is `-1.0` if [Directionality.of] returns
  /// [TextDirection.ltr], and `1.0` if [Directionality.of] returns
  /// [TextDirection.rtl].	 Similarly [AlignmentDirectional.centerEnd] is the
  /// same as an [Alignment] whose [Alignment.x] value is `1.0` if
  /// [Directionality.of] returns	 [TextDirection.ltr], and `-1.0` if
  /// [Directionality.of] returns [TextDirection.rtl].
  final AlignmentGeometry? rotateAlignment;

  /// The marker is displayed when the map is zoomed in larger than the set number.
  final double priority;

  /// The unique ID that the marker has
  final int id;

  PriorityMarker({
    this.key,
    required this.point,
    required this.priority,
    required this.builder,
    this.width = 30.0,
    this.height = 30.0,
    this.anchorPos,
    this.rotate,
    this.rotateOrigin,
    this.rotateAlignment,
  }) : id = ++lastId;
}

class PriorityMarkerLayer extends StatefulWidget {
  final List<PriorityMarker> markers;

  /// Positioning of the [Marker.builder] widget relative to the center of its
  /// bounding box defined by its [Marker.height] & [Marker.width]
  ///
  /// Overriden on a per [Marker] basis if [Marker.anchorPos] is specified.
  final AnchorPos? anchorPos;

  /// Whether to counter rotate markers to the map's rotation, to keep a fixed
  /// orientation
  ///
  /// Overriden on a per [Marker] basis if [Marker.rotate] is specified.
  final bool rotate;

  /// The origin of the coordinate system (relative to the upper left corner of
  /// this render object) in which to apply the matrix.
  ///
  /// Setting an origin is equivalent to conjugating the transform matrix by a
  /// translation. This property is provided just for convenience.
  ///
  /// Overriden on a per [Marker] basis if [Marker.rotateOrigin] is specified.
  final Offset? rotateOrigin;

  /// The alignment of the origin, relative to the size of the box.
  ///
  /// This is equivalent to setting an origin based on the size of the box.
  /// If it is specified at the same time as the [rotateOrigin], both are applied.
  ///
  /// An [AlignmentDirectional.centerStart] value is the same as an [Alignment]
  /// whose [Alignment.x] value is `-1.0` if [Directionality.of] returns
  /// [TextDirection.ltr], and `1.0` if [Directionality.of] returns
  /// [TextDirection.rtl].	 Similarly [AlignmentDirectional.centerEnd] is the
  /// same as an [Alignment] whose [Alignment.x] value is `1.0` if
  /// [Directionality.of] returns	 [TextDirection.ltr], and `-1.0` if
  /// [Directionality.of] returns [TextDirection.rtl].
  ///
  /// Overriden on a per [Marker] basis if [Marker.rotateAlignment] is specified.
  final AlignmentGeometry? rotateAlignment;

  const PriorityMarkerLayer({
    super.key,
    this.markers = const [],
    this.anchorPos,
    this.rotate = false,
    this.rotateOrigin,
    this.rotateAlignment = Alignment.center,
  });

  @override
  State<PriorityMarkerLayer> createState() => _PriorityMarkerLayerState();
}

class _PriorityMarkerLayerState extends State<PriorityMarkerLayer> {
  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.of(context);
    final markerWidgets = <Widget>[];

    for (final marker in widget.markers) {
      if (map.zoom < marker.priority) continue;

      final pxPoint = map.project(marker.point);

      // See if any portion of the Marker rect resides in the map bounds
      // If not, don't spend any resources on build function.
      // This calculation works for any Anchor position whithin the Marker
      // Note that Anchor coordinates of (0,0) are at bottom-right of the Marker
      // unlike the map coordinates.
      final anchor = Anchor.fromPos(
        marker.anchorPos ??
            widget.anchorPos ??
            AnchorPos.align(AnchorAlign.center),
        marker.width,
        marker.height,
      );
      final rightPortion = marker.width - anchor.left;
      final leftPortion = anchor.left;
      final bottomPortion = marker.height - anchor.top;
      final topPortion = anchor.top;
      if (!map.pixelBounds.containsPartialBounds(Bounds(
          CustomPoint(pxPoint.x + leftPortion, pxPoint.y - bottomPortion),
          CustomPoint(pxPoint.x - rightPortion, pxPoint.y + topPortion)))) {
        continue;
      }

      final pos = pxPoint - map.pixelOrigin;
      final markerWidget = (marker.rotate ?? widget.rotate)
          ? Transform.rotate(
              angle: -map.rotationRad,
              origin: marker.rotateOrigin ?? widget.rotateOrigin ?? Offset.zero,
              alignment: marker.rotateAlignment ?? widget.rotateAlignment,
              child: marker.builder(context),
            )
          : marker.builder(context);

      markerWidgets.add(
        Positioned(
          key: marker.key,
          width: marker.width,
          height: marker.height,
          left: pos.x - rightPortion,
          top: pos.y - bottomPortion,
          child: markerWidget,
        ),
      );
    }
    return Stack(children: markerWidgets);
  }
}
