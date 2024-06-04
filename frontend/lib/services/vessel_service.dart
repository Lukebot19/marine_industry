import 'dart:convert';

import 'package:frontend/models/vessel.dart';
import 'package:http/http.dart' as http;

import '../API_config.dart';

class VeesselService {

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
}
