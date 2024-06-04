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

    final response = await http.get(Uri.parse('${config.API_URL}/vessels/'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Vessel> vessels = data.map((e) => Vessel.fromMap(e)).toList();
      return vessels;
    } else {
      throw Exception('Failed to load vessels');
    }
  }

  // Update a vessel
  Future<void> updateVessel(Vessel vessel) async {
    APIConfig config = APIConfig();
    if (config.development) {
      return;
    }

    final response = await http.put(
      Uri.parse('${config.API_URL}/vessels/${vessel.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(vessel.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update vessel');
    }
  }

  // Add a vessel
  Future<void> addVessel(Vessel vessel) async {
    APIConfig config = APIConfig();
    if (config.development) {
      return;
    }

    final response = await http.post(
      Uri.parse('${config.API_URL}/vessels/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(vessel.toMap()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add vessel');
    }
  }

  // Retrieve a vessel
  Future<Vessel> getVessel(String id) async {
    APIConfig config = APIConfig();
    if (config.development) {
      return Vessel.dummyData.firstWhere((element) => element.id == id);
    }

    final response = await http.get(Uri.parse('${config.API_URL}/vessels/$id/'));

    if (response.statusCode == 200) {
      return Vessel.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load vessel');
    }
  }

  // Delete a vessel
  Future<void> deleteVessel(String id) async {
    APIConfig config = APIConfig();
    if (config.development) {
      return;
    }

    final response = await http.delete(Uri.parse('${config.API_URL}/vessels/$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete vessel');
    }
  }

}
