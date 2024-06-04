import 'package:flutter/material.dart';
import 'package:frontend/pages/map.dart';
import 'package:frontend/widgets/mapDrawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        drawer: mapDrawer(),
        body: MapPage(),
      ),
    );
  }
}
