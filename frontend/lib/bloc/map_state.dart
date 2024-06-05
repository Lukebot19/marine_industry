part of 'map_bloc.dart';

class MapState {
  final bool loading;
  final List<Vessel> vessels;
  final MapController controller;

  MapState({
    this.loading = false,
    this.vessels = const [],
    required this.controller,
  });

  MapState copyWith({
    bool? loading,
    List<Vessel>? vessels,
    MapController? controller,
  }) {
    return MapState(
      loading: loading ?? this.loading,
      vessels: vessels ?? this.vessels,
      controller: controller ?? this.controller,
    );
  }
}
