import 'package:flutter/material.dart';
import 'package:frontend/models/vessel.dart';
import 'package:frontend/states/map_state.dart';
import 'package:frontend/widgets/base_widget.dart';
import 'package:frontend/widgets/mapDrawer.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapState();
}

class _MapState extends State<MapPage> {
  Widget _buildMarkerWidget(
      Vessel vessel, Color color, MapTransformer transformer,
      [IconData icon = Icons.directions_boat]) {
    LatLng position =
        LatLng(Angle.degree(vessel.latitude), Angle.degree(vessel.longitude));
    Offset pos = transformer.toOffset(position);
    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 24,
      width: 48,
      height: 48,
      child: GestureDetector(
        child: Icon(
          icon,
          color: color,
          size: 48,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Vessel Name: ${vessel.name}'),
                  Text('Longitude: ${vessel.longitude}'),
                  Text('Latitude: ${vessel.latitude}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;
  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer,
      MapController controller) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;
      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      transformer.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  double clamp(double x, double min, double max) {
    if (x < min) x = min;
    if (x > max) x = max;

    return x;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseWidget<MapState>(
        state: Provider.of<MapState>(context),
        onStateReady: (state) async {
          state.setLoading(true);
          await state.getMarkers();
          state.setLoading(false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        },
        builder: (context, state, child) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Map Page'),
              ),
              drawer: const mapDrawer(),
              body: MapLayout(
                controller: state.controller,
                builder: (context, transformer) {
                  final markerWidgets = state.vessels.map(
                    (vessel) =>
                        _buildMarkerWidget(vessel, Colors.red, transformer),
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: (details) =>
                        _onScaleUpdate(details, transformer, state.controller),
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerSignal: (event) {
                        if (event is PointerScrollEvent) {
                          final delta = event.scrollDelta.dy / -1000.0;
                          final zoom =
                              clamp(state.controller.zoom + delta, 2, 18);

                          transformer.setZoomInPlace(zoom, event.localPosition);
                          setState(() {});
                        }
                      },
                      child: Stack(
                        children: [
                          TileLayer(
                            builder: (context, x, y, z) {
                              final tilesInZoom = pow(2.0, z).floor();

                              while (x < 0) {
                                x += tilesInZoom;
                              }
                              while (y < 0) {
                                y += tilesInZoom;
                              }

                              x %= tilesInZoom;
                              y %= tilesInZoom;

                              //Google Maps
                              final url =
                                  'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

                              return CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          ...markerWidgets,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
