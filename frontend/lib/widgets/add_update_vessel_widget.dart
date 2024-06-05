import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/map_bloc.dart';
import 'package:frontend/models/vessel.dart';

class AddUpdateVesselDialog extends StatefulWidget {
  final Vessel? vessel;

  AddUpdateVesselDialog({this.vessel});

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
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return AlertDialog(
          title:
              Text(widget.vessel == null ? 'Add a vessel' : 'Update vessel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
              TextFormField(
                controller: latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
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
                  if (double.parse(longitudeController.text) >= 180 ||
                      double.parse(longitudeController.text) <= -180) {
                    setState(() {
                      errorMessage = 'Longitude must be between -180 and 180';
                    });
                    return;
                  }
                  if (double.parse(latitudeController.text) >= 90 ||
                      double.parse(latitudeController.text) <= -90) {
                    setState(() {
                      errorMessage = 'Latitude must be between -90 and 90';
                    });
                    return;
                  }
                  widget.vessel == null
                      ? context.read<MapBloc>().add(
                            VesselAdd(
                              nameController.text,
                              double.parse(
                                longitudeController.text,
                              ),
                              double.parse(
                                latitudeController.text,
                              ),
                            ),
                          )
                      : context.read<MapBloc>().add(
                            VesselEdit(
                              widget.vessel!,
                              nameController.text,
                              double.parse(
                                longitudeController.text,
                              ),
                              double.parse(
                                latitudeController.text,
                              ),
                            ),
                          );
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
      },
    );
  }
}
