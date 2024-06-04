import 'dart:convert';

import 'package:frontend/models/vessel.dart';
import 'package:http/http.dart' as http;

import '../API_config.dart';

class VeesselService {

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

}
