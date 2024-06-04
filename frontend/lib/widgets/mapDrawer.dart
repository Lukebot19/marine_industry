import 'package:flutter/material.dart';
import 'package:frontend/states/map_state.dart';
import 'package:provider/provider.dart';

class mapDrawer extends StatelessWidget {
  const mapDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              Provider.of<MapState>(context).isLoading == false
                  ? Column(
                      children: [
                        ...Provider.of<MapState>(context).vessels.map(
                          (vessel) {
                            return ListTile(
                              title: Text(vessel.name),
                              onTap: () {
                                // Provider.of<MapState>(context, listen: false).selectVessel(vessel);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
          if (Provider.of<MapState>(context).isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
