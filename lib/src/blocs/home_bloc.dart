import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc {
  Completer<GoogleMapController> _controller = Completer();
  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  final CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414
  );
  MapType _mapType = MapType.normal;
  final PublishSubject<MapType> _mapTypeFetcher = PublishSubject<MapType>();

  Completer<GoogleMapController> get controller => _controller;
  CameraPosition get kGooglePlex => _kGooglePlex;
  Observable<MapType> get mapTypeFetcher => _mapTypeFetcher.stream;
  MapType get mapType => _mapType;

  Future<void> goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void changeVisualization() {
    int nextIndexMapType = _mapType.index + 1;
    if (MapType.values.length <= nextIndexMapType)
      nextIndexMapType = 0;
    _mapType = MapType.values[nextIndexMapType];
    _mapTypeFetcher.sink.add(_mapType);
  }

  dispose() {
    _mapTypeFetcher.close();
  }
}