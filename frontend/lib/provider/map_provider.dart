import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/map_state.dart';

class MapProvider extends StatelessWidget {
  final Widget child;

  const MapProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapState>(
      create: (_) => MapState(),
      child: child,
    );
  }
}
