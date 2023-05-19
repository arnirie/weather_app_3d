import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({super.key, required this.position});

  final LatLng position;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Text('${position}'),
      ),
    );
  }
}
