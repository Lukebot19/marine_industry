import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/map_bloc.dart';
import 'package:frontend/models/vessel.dart';
import 'package:frontend/widgets/add_update_vessel_widget.dart';
import 'package:frontend/widgets/mapDrawer.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapState();
}

class _MapState extends State<MapPage> {
  Widget _buildMarkerWidget(Vessel vessel, Color color,
      MapTransformer transformer, MapState state, BuildContext passedContext,
      [IconData icon = Icons.directions_boat]) {
    double longitude = vessel.longitude;
    while (longitude > 180) {
      longitude -= 360;
    }
    while (longitude < -180) {
      longitude += 360;
    }

    LatLng position =
        LatLng(Angle.degree(vessel.latitude), Angle.degree(longitude));
    Offset pos = transformer.toOffset(position);
    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 24,
      width: 48,
      height: 60,
      child: GestureDetector(
        child: Column(
          children: [
            Text(
              vessel.name,
              style: TextStyle(
                color: color,
              ),
            ),
            SizedBox(height: 3),
            Icon(
              icon,
              color: color,
              size: 37,
            ),
          ],
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
              actions: <Widget>[
                TextButton(
                  child: const Text('Update'),
                  onPressed: () {
                    // Close the current dialog
                    Navigator.of(context).pop();

                    // Show the VesselDialog in update mode
                    showDialog(
                      context: context,
                      builder: (context) => AddUpdateVesselDialog(
                        vessel: vessel,
                      ),
                    );
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    // Delete the vessel from the system
                    passedContext.read<MapBloc>().add(
                          VesselDelete(
                            vessel.id,
                          ),
                        );
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                ),
              ],
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
      if (controller.zoom < 1) {
        controller.zoom = 1;
      }
      setState(() {});
    } else {
      final now = details.focalPoint;
      var diff = now - _dragStart!;
      _dragStart = now;
      final h = transformer.constraints.maxHeight;

      final vp = transformer.getViewport();
      if (diff.dy < 0 && vp.bottom - diff.dy < h) {
        diff = Offset(diff.dx, 0);
      }

      if (diff.dy > 0 && vp.top - diff.dy > 0) {
        diff = Offset(diff.dx, 0);
      }

      final w = transformer.constraints.maxWidth;
      if (diff.dx < 0 && vp.right - diff.dx < w) {
        diff = Offset(0, diff.dy);
      }

      if (diff.dx > 0 && vp.left - diff.dx > 0) {
        diff = Offset(0, diff.dy);
      }

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
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
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
                  (vessel) => _buildMarkerWidget(
                      vessel, Colors.red, transformer, state, context),
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
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    context.read<MapBloc>().add(CenterMap());
                  },
                  child: const Icon(Icons.center_focus_weak_rounded),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddUpdateVesselDialog(),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
