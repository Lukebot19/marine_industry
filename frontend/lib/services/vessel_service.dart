import 'dart:convert';

import 'package:frontend/models/vessel.dart';
import 'package:http/http.dart' as http;

import '../API_config.dart';

class VesselService {
  // Get all vessels
  Future<List<Vessel>> getVessels() async {
    APIConfig config = APIConfig();
    if (config.development) {
      return Vessel.dummyData;
    }
    try {
      final response = await http
          .get(Uri.parse('${config.API_URL}vessels/'), headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Vessel> vessels = data.map((e) => Vessel.fromMap(e)).toList();
        return vessels;
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Update a vessel
  Future<void> updateVessel(Vessel vessel) async {
    APIConfig config = APIConfig();
    if (config.development) {
      return;
    }

    final response = await http.put(
      Uri.parse('${config.API_URL}vessels/${vessel.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(vessel.toMap()),
    );

    if (response.statusCode != 200) {
      return;
    }
  }

  // Add a vessel
  Future<Vessel?> addVessel(
      String name, double longitude, double latitude) async {
    APIConfig config = APIConfig();
    if (config.development) {
      return null;
    }

    Map tempVessel = {
      'name': name,
      'longitude': longitude,
      'latitude': latitude,
    };

    final response = await http.post(
      Uri.parse('${config.API_URL}vessels/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(tempVessel),
    );

    if (response.statusCode != 201) {
      return null;
    }

    return Vessel.fromMap(jsonDecode(response.body));
  }

  // Retrieve a vessel
  Future<Vessel?> getVessel(String id) async {
    APIConfig config = APIConfig();
    if (config.development) {
      return Vessel.dummyData.firstWhere((element) => element.id == id);
    }

    final response = await http.get(Uri.parse('${config.API_URL}vessels/$id/'));

    if (response.statusCode == 200) {
      return Vessel.fromMap(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  // Delete a vessel
  Future<void> deleteVessel(String id) async {
    APIConfig config = APIConfig();
    if (config.development) {
      return;
    }

    final response =
        await http.delete(Uri.parse('${config.API_URL}vessels/$id/'));

    if (response.statusCode != 204) {
      return;
    }
  }
}
