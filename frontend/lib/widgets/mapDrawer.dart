import 'package:flutter/material.dart';
import 'package:frontend/states/map_state.dart';
import 'package:provider/provider.dart';

class mapDrawer extends StatefulWidget {
  const mapDrawer({
    super.key,
  });

  @override
  _mapDrawerState createState() => _mapDrawerState();
}

class _mapDrawerState extends State<mapDrawer> {
  String filter = '';
  bool isAscending = true;

  @override
  Widget build(BuildContext context) {
    var vessels = Provider.of<MapState>(context).vessels;
    var filteredVessels = vessels
        .where((vessel) =>
            vessel.name.toLowerCase().contains(filter.toLowerCase()))
        .toList();

    filteredVessels.sort((a, b) {
      return isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
    });

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
                child: Text('Vessel Menu'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            filter = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Search",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isAscending = !isAscending;
                        });
                      },
                      icon: const Icon(Icons.filter_list),
                    ),
                  ],
                ),
              ),
              Provider.of<MapState>(context).isLoading == false
                  ? Column(
                      children: [
                        ...filteredVessels.map(
                          (vessel) {
                            return ListTile(
                              title: Text(vessel.name),
                              onTap: () {
                                Provider.of<MapState>(context, listen: false)
                                    .selectVessel(vessel);
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
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
