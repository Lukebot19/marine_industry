import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/vessel.dart';
import 'package:frontend/states/map_state.dart';
import 'package:provider/provider.dart';

class AddUpdateVesselDialog extends StatefulWidget {
  final Vessel? vessel;
  MapState state;

  AddUpdateVesselDialog({this.vessel, required this.state});

  @override
  _AddUpdateVesselDialogState createState() => _AddUpdateVesselDialogState();
}

class _AddUpdateVesselDialogState extends State<AddUpdateVesselDialog> {
  late TextEditingController nameController;
  late TextEditingController longitudeController;
  late TextEditingController latitudeController;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.vessel?.name ?? '');
    longitudeController =
        TextEditingController(text: widget.vessel?.longitude.toString() ?? '');
    latitudeController =
        TextEditingController(text: widget.vessel?.latitude.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vessel == null ? 'Add a vessel' : 'Update vessel'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextFormField(
            controller: longitudeController,
            decoration: InputDecoration(labelText: 'Longitude'),
          ),
          TextFormField(
            controller: latitudeController,
            decoration: InputDecoration(labelText: 'Latitude'),
          ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(widget.vessel == null ? 'Add' : 'Update'),
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                longitudeController.text.isNotEmpty &&
                latitudeController.text.isNotEmpty) {
              widget.vessel == null
                  ? widget.state.addVessel(
                      nameController.text,
                      double.parse(longitudeController.text),
                      double.parse(latitudeController.text))
                  : widget.state.updateVessel(
                      widget.vessel!,
                      nameController.text,
                      double.parse(longitudeController.text),
                      double.parse(latitudeController.text));
              Navigator.of(context).pop();
            } else {
              setState(() {
                errorMessage = 'Please fill all the fields';
              });
            }
          },
        ),
      ],
    );
  }
}
