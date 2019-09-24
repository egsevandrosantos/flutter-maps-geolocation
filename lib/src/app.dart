import 'package:flutter/material.dart';
import 'package:maps_geolocation/src/ui/home.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps and Geolocation',
      debugShowCheckedModeBanner: false,
      home: Home()
    );
  }
}