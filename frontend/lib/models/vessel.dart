class Vessel {
  final String id;
  final String name;
  final double longitude;
  final double latitude;

  Vessel({required this.id, required this.name, required this.longitude,required this.latitude});

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
}
