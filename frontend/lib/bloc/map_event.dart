part of 'map_bloc.dart';

class MapEvent {}

class GetMarkers extends MapEvent {}

class CenterMap extends MapEvent {}

class WebSocketDelete extends MapEvent {
  final int id;

  WebSocketDelete(this.id);
}

class WebSocketAddOrEdit extends MapEvent {
  final Map data;

  WebSocketAddOrEdit(this.data);
}

class VesselAdd extends MapEvent {
  final String name;
  final double longitude;
  final double latitude;

  VesselAdd(this.name, this.longitude, this.latitude);
}

class VesselEdit extends MapEvent {
  final Vessel vessel;
  final String name;
  final double longitude;
  final double latitude;

  VesselEdit(this.vessel, this.name, this.longitude, this.latitude);
}

class VesselDelete extends MapEvent {
  final int id;

  VesselDelete(this.id);
}

class VesselSelect extends MapEvent {
  final Vessel vessel;

  VesselSelect(this.vessel);
}
