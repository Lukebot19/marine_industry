class Vessel {
  final int id;
  String name;
  double longitude;
  double latitude;

  Vessel(
      {required this.id,
      required this.name,
      required this.longitude,
      required this.latitude});

  // Named constructor that initializes a Vessel from a map
  Vessel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        longitude = map['longitude'],
        latitude = map['latitude'];

  // Method that converts a Vessel to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  // Dummy data
  static List<Vessel> dummyData = [
    Vessel(id: 1, name: 'Vessel 1', longitude: 35.674, latitude: 51.41),
    Vessel(id: 2, name: 'Vessel 2', longitude: 5.678, latitude: 51.41),
    Vessel(id: 3, name: 'Vessel 3', longitude: 25.682, latitude: 51.41),
    Vessel(id: 4, name: 'Vessel 4', longitude: 36.686, latitude: 51.41),
  ];
}
