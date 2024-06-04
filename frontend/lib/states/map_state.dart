import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/API_config.dart';
import 'package:frontend/models/vessel.dart';
import 'package:frontend/services/vessel_service.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MapState extends ChangeNotifier {
  // Declare Variables
  List<Vessel> _vessels = [];
  final MapController _controller = MapController(
    location: const LatLng(Angle.degree(35.675), Angle.degree(51.41)),
    zoom: 2,
  );
  bool _loading = false;
  VesselService _vesselService = VesselService();

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
    List<Vessel> vessels = await _vesselService.getVessels();
    setVessels(vessels);
  }

  // Connect to websocket
  void connectToWebSocket() {
    // Connect to the websocket
    try {
      final channel = WebSocketChannel.connect(Uri.parse(APIConfig().WS_URL));
      // Listen to the websocket
      channel.stream.listen((message) {
        // Parse the message
        dynamic data = jsonDecode(message);
        if (data['type'] == 'vessel.delete') {
          // Delete the vessel
          _vessels.removeWhere((vessel) => vessel.id == data['id']);
          // Notify the listeners
          if (hasListeners) {
            notifyListeners();
          }
          return;
        } else {
          data = jsonDecode(data['data']).first;
          // Add the vessel if it does not exist or update it
          if (!_vessels.any((vessel) => vessel.id == data['pk'])) {
            _vessels.add(Vessel(
              id: data['pk'],
              name: data['fields']['name'],
              longitude: data['fields']['longitude'],
              latitude: data['fields']['latitude'],
            ));
          } else {
            Vessel vessel =
                _vessels.firstWhere((vessel) => vessel.id == data['pk']);
            vessel.longitude = data['fields']['longitude'];
            vessel.latitude = data['fields']['latitude'];
            vessel.name = data['fields']['name'];
          }
        }
        // Notify the listeners
        if (hasListeners) {
          notifyListeners();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // Select a vessel
  void selectVessel(Vessel vessel) {
    // Zoom in the map to the selected vessel
    _controller.center =
        LatLng(Angle.degree(vessel.latitude), Angle.degree(vessel.longitude));
    _controller.zoom = 7;
    if (hasListeners) {
      notifyListeners();
    }
  }

  // Add a vessel
  void addVessel(String name, double longitude, double latitude) async {
    // Call API to add the vessel
    await _vesselService.addVessel(name, longitude, latitude);

    if (hasListeners) {
      notifyListeners();
    }
  }

  // Update a vessel
  void updateVessel(
      Vessel vessel, String name, double longitude, double latitude) async {
    // Update the vessel with the same id
    vessel.name = name;
    vessel.longitude = longitude;
    vessel.latitude = latitude;
    // Call API to update the vessel
    await _vesselService.updateVessel(vessel);
    // Update the vessel in the list of vessels
    if (hasListeners) {
      notifyListeners();
    }
  }

  // Delete a vessel
  void deleteVessel(int id) async {
    // Call API to delete the vessel
    await _vesselService.deleteVessel(id);
    // Delete the vessel from the list of vessels
    _vessels.removeWhere((vessel) => vessel.id == id);
    if (hasListeners) {
      notifyListeners();
    }
  }
}
