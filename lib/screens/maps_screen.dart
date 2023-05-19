// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_3d/screens/new_screen.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  static LatLng _initialPosition =
      LatLng(16.04608831763451, 120.59283850660992);
  late GoogleMapController _mapController;

  List<Marker> _markers = [
    Marker(
      markerId: MarkerId('initial'),
      position: _initialPosition,
      infoWindow: InfoWindow(title: 'Initial Location'),
    ),
  ];

  Future<bool> checkServicePermission() async {
    LocationPermission locationPermission;
    //check service
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location services is disabled. Please enable in the Settings.'),
        ),
      );
      return false;
    }
    //check permission
    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      //request
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Location permission is denied. You cannot use the app without allowing location pemission.'),
          ),
        );
        return false;
      }
    }
    if (locationPermission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location permission is denied. Please enable in the settings'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> getLocation() async {
    if (!await checkServicePermission()) {
      return;
    }
    await Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      print(pos);
      updateCameraPosition(LatLng(pos.latitude, pos.longitude));
    });
  }

  void updateCameraPosition(LatLng pos) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId('${pos.latitude + pos.longitude}'),
        position: pos,
        infoWindow: InfoWindow(
          title: 'My Location',
        ),
      ),
    );
    //create a new Camera Position
    CameraPosition _cameraPos = CameraPosition(target: pos, zoom: 18);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(_cameraPos));
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          // mapType: MapType.hybrid,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 18,
            bearing: 0,
            tilt: 0,
          ),
          onTap: (pos) {
            print(pos);
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (_) => NewScreen(position: pos)));
            updateCameraPosition(pos);
          },
          markers: _markers.toSet(),
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
      ),
    );
  }
}
