import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_geolocation/src/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
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
  PermissionService _permissionService = PermissionService();
  final PublishSubject<bool> _checkPermissionLocalIsLoadingFetcher = PublishSubject<bool>();

  Completer<GoogleMapController> get controller => _controller;
  CameraPosition get kGooglePlex => _kGooglePlex;
  Observable<MapType> get mapTypeFetcher => _mapTypeFetcher.stream;
  MapType get mapType => _mapType;
  Observable<bool> get checkPermissionLocalIsLoadingFetcher => _checkPermissionLocalIsLoadingFetcher.stream;

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
    _checkPermissionLocalIsLoadingFetcher.close();
  }

  Future<void> checkPermissionLocal() async {
    _checkPermissionLocalIsLoadingFetcher.sink.add(true);
    bool havePermission = await _permissionService.checkPermission(PermissionGroup.location);
    if (!havePermission) await requestPermissionLocal();
    _checkPermissionLocalIsLoadingFetcher.sink.add(false);
  }

  Future<void> requestPermissionLocal() async {
    await _permissionService.requestPermission(PermissionGroup.location);
  }
}