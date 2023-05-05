import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({super.key});

  @override
  State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  Position? currentPosition;

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

  Future<void> getCurrentLocation() async {
    if (!await checkServicePermission()) {
      return;
    }
    //get gps location if the service and pemission is ok
    await Geolocator.getCurrentPosition().then((position) {
      print(position);
      setState(() {
        currentPosition = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lat: ${currentPosition?.latitude ?? ''}'),
            Text('Long: ${currentPosition?.longitude ?? ''}'),
            ElevatedButton(
              onPressed: getCurrentLocation,
              child: const Text('Get Current Location'),
            ),
          ],
        ),
      ),
    );
  }
}
