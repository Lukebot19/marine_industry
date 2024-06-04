import 'package:flutter/material.dart';
import 'package:frontend/models/vessel.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

class MapState extends ChangeNotifier {
  // Declare Variables
  List<Vessel> _vessels = [];
  final MapController _controller = MapController(
    location: const LatLng(Angle.degree(35.675), Angle.degree(51.41)),
    zoom: 2,
  );
  bool _loading = false;

  // Getters
  MapController get controller => _controller;
  List<Vessel> get vessels => _vessels;
  bool get isLoading => _loading;

  // Setters
  void setVessels(List<Vessel> vessels) {
    _vessels = vessels;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _loading = loading;
    if (hasListeners) {
      notifyListeners();
    }
  }

  // Retrieve the markers from the backend
  Future<void> getMarkers() async {
    // Call the backend
    // For now, we will use dummy data
    setVessels(Vessel.dummyData);
  }

  // Select a vessel
  void selectVessel(Vessel vessel) {
    // Zoom in the map to the selected vessel
    _controller.center =
        LatLng(Angle.degree(vessel.longitude), Angle.degree(vessel.latitude));
    _controller.zoom = 7;
    if (hasListeners) {
      notifyListeners();
    }
  }
}
