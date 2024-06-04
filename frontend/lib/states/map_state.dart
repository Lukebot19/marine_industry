import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

class MapState extends ChangeNotifier {
  // Declare Variables
  List<LatLng> _markers = [];
  final MapController _controller = MapController(
    location: const LatLng(Angle.degree(35.675), Angle.degree(51.41)),
    zoom: 2,
  );

  // Getters
  List<LatLng> get markers => _markers;
  MapController get controller => _controller;

  // Setters
  void setMarkers(List<LatLng> markers) {
    _markers = markers;
    notifyListeners();
  }

  // Retrieve the markers from the backend
  Future<void> getMarkers() async {
    // Call the backend
    // Set the markers
    setMarkers([
      const LatLng(Angle.degree(35.674), Angle.degree(51.41)),
      const LatLng(Angle.degree(5.678), Angle.degree(51.41)),
      const LatLng(Angle.degree(25.682), Angle.degree(51.41)),
      const LatLng(Angle.degree(36.686), Angle.degree(51.41)),
    ]);
  }
}
