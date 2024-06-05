import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:frontend/API_config.dart';
import 'package:frontend/models/vessel.dart';
import 'package:frontend/services/vessel_service.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final VesselService _vesselService = VesselService();

  MapBloc()
      : super(
          MapState(
            controller: MapController(
              location: const LatLng(Angle.degree(35.675), Angle.degree(51.41)),
              zoom: 2,
            ),
          ),
        ) {
    on<GetMarkers>((event, emit) async {
      emit(state.copyWith(loading: true));

      List<Vessel> vessels = await _vesselService.getVessels();

      emit(state.copyWith(vessels: vessels, loading: false));
    });

    on<VesselAdd>((event, emit) async {
      await _vesselService.addVessel(
        event.name,
        event.longitude,
        event.latitude,
      );
    });

    on<VesselEdit>((event, emit) async {
      event.vessel.name = event.name;
      event.vessel.latitude = event.latitude;
      event.vessel.longitude = event.longitude;

      await _vesselService.updateVessel(event.vessel);
    });

    on<VesselDelete>((event, emit) async {
      await _vesselService.deleteVessel(event.id);
    });

    on<VesselSelect>((event, emit) {
      state.controller.center = LatLng(
        Angle.degree(event.vessel.latitude),
        Angle.degree(event.vessel.longitude),
      );
      state.controller.zoom = 7;

      // Emit a new state with the new controller
      emit(state.copyWith(controller: state.controller));
    });

    on<WebSocketDelete>((event, emit) {
      try {
        state.vessels.removeWhere((vessel) => vessel.id == event.id);
        emit(state.copyWith(vessels: state.vessels));
      } catch (e) {
        print(e);
      }
    });

    on<WebSocketAddOrEdit>((event, emit) {
      // Add the vessel if it does not exist or update it
      if (!state.vessels.any((vessel) => vessel.id == event.data['pk'])) {
        state.vessels.add(Vessel(
          id: event.data['pk'],
          name: event.data['fields']['name'],
          longitude: event.data['fields']['longitude'],
          latitude: event.data['fields']['latitude'],
        ));
        try {
          emit(state.copyWith(vessels: state.vessels));
        } catch (e) {
          print(e);
        }
      } else {
        Vessel vessel =
            state.vessels.firstWhere((vessel) => vessel.id == event.data['pk']);
        vessel.longitude = event.data['fields']['longitude'];
        vessel.latitude = event.data['fields']['latitude'];
        vessel.name = event.data['fields']['name'];
        emit(state.copyWith(vessels: state.vessels));
      }
    });

    add(GetMarkers());

    final channel = WebSocketChannel.connect(Uri.parse(APIConfig().WS_URL));
    // Listen to the websocket
    channel.stream.listen((message) {
      try {
        // Parse the message
        dynamic data = jsonDecode(message);
        if (data['type'] == 'vessel.delete') {
          // Delete the vessel
          add(WebSocketDelete(data['data']['id']));
          return;
        } else {
          data = jsonDecode(data['data']).first;
          add(WebSocketAddOrEdit(data));
        }
      } catch (e) {
        print(e);
      }
    });
  }
}
