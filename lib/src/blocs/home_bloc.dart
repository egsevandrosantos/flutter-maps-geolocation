import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_geolocation/src/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc {
  Completer<GoogleMapController> _controller = Completer();
  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14
  );
  CameraPosition _currentPosition;
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
  Set<Marker> _markers = Set<Marker>();
  final PublishSubject<Set<Marker>> _markersFetcher = PublishSubject<Set<Marker>>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();

  Completer<GoogleMapController> get controller => _controller;
  CameraPosition get kGooglePlex => _kGooglePlex;
  CameraPosition get currentPosition => _currentPosition;
  Observable<MapType> get mapTypeFetcher => _mapTypeFetcher.stream;
  MapType get mapType => _mapType;
  Observable<bool> get checkPermissionLocalIsLoadingFetcher => _checkPermissionLocalIsLoadingFetcher.stream;
  Set<Marker> get markers => _markers;
  Observable<Set<Marker>> get markersFetcher => _markersFetcher.stream;
  Set<Polygon> get polygons => _polygons;
  Set<Polyline> get polylines => _polylines;

  Future<void> goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void createMarkers() {
    _markers = Set<Marker>();

    Marker markerSpaceCoffee = Marker(
      markerId: MarkerId("space-coffee"),
      position: LatLng(-21.764177, -48.170265),
      infoWindow: InfoWindow(
        title: "Espaço Café Araraquara"
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueMagenta
      ),
      rotation: 270,
      onTap: () {
        print('Espaço Café Araraquara');
      }
    );
    _markers.add(markerSpaceCoffee);

    Marker markerAcademy = Marker(
      markerId: MarkerId("academy"),
      position: LatLng(-21.762896, -48.167946),
      infoWindow: InfoWindow(
        title: "Miskey Academia"
      )
    );
    _markers.add(markerAcademy);

    _markersFetcher.sink.add(_markers);
  }

  void createPolygons() {
    _polygons = Set<Polygon>();

    Polygon polygon1 = new Polygon(
      polygonId: PolygonId("polygon1"),
      fillColor: Colors.green,
      strokeColor: Colors.red,
      strokeWidth: 10,
      points: [
        LatLng(-21.763881, -48.171318),
        LatLng(-21.763772, -48.170586),
        LatLng(-21.764095, -48.170463)
      ],
      consumeTapEvents: true,
      onTap: () {
        print('Polygon');
      },
      zIndex: 1
    );
    _polygons.add(polygon1);

    Polygon polygon2 = new Polygon(
      polygonId: PolygonId("polygon2"),
      fillColor: Colors.blue,
      strokeColor: Colors.yellow,
      strokeWidth: 10,
      points: [
        LatLng(-21.764358, -48.171186),
        LatLng(-21.763850, -48.171524),
        LatLng(-21.763591, -48.170548),
        LatLng(-21.764069, -48.170258)
      ],
      consumeTapEvents: true,
      onTap: () {
        print('Polygon');
      },
      zIndex: 0
    );
    _polygons.add(polygon2);
  }

  void createPolylines() {
    _polylines = Set<Polyline>();

    Polyline polyline1 = new Polyline(
      polylineId: PolylineId("polyline1"),
      color: Colors.red,
      width: 20,
      points: [
        LatLng(-21.762710, -48.167966),
        LatLng(-21.763682, -48.169103),
        LatLng(-21.762425, -48.169247)
      ],
      startCap: Cap.roundCap,
      endCap: Cap.squareCap,
      jointType: JointType.bevel,
      consumeTapEvents: true,
      onTap: () {
        print('Polyline');
      }
    );
    _polylines.add(polyline1);
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
    _markersFetcher.close();
  }

  Future<void> getCurrentPosition() async {
    GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();
    if (geolocationStatus == GeolocationStatus.granted) {
      listenerGeolocation();
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _currentPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 18
      );
    }
  }

  void listenerGeolocation() {
    LocationOptions locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high, 
      distanceFilter: 10
    );

    Geolocator().getPositionStream(locationOptions).listen((Position position) {
      if (position != null) 
        moveCamera(position: position);  
    });
  }

  Future<void> checkPermissionLocal() async {
    _checkPermissionLocalIsLoadingFetcher.sink.add(true);
    bool havePermission = await _permissionService.checkPermission(PermissionGroup.location);
    if (!havePermission) await requestPermissionLocal();
    await this.getCurrentPosition();
    _checkPermissionLocalIsLoadingFetcher.sink.add(false);
  }

  Future<void> requestPermissionLocal() async {
    await _permissionService.requestPermission(PermissionGroup.location);
  }

  void moveCamera({Position position}) async {
    GoogleMapController googleMapController = await _controller.future;
    if (position != null) {
      Marker markerUser = Marker(
        markerId: MarkerId('position-user'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
          title: "Meu local"
        )
      );
      Marker markerUserOnList;
      //StateError (Bad state: No element)
      try {
        markerUserOnList = markers.firstWhere((marker) => marker != null && marker.markerId.value == markerUser.markerId.value);
      } on StateError catch (err) {
        if (err.message == 'No element')
          markerUserOnList = null;
        else
          throw new Exception(err.message);
      }
      
      if (markerUserOnList != null)
        markerUserOnList = markerUser;
      else
        _markers.add(markerUser);

      _markersFetcher.sink.add(_markers);
      
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16,
          )
        )
      );    
    } else {
      LatLngBounds currentRegion = await googleMapController.getVisibleRegion();
      LatLng center = calculeCenterByRegion(currentRegion);
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: center,
            zoom: 14,
            tilt: 60,
            bearing: 180
          )
        )
      );
    }
  }

  LatLng calculeCenterByRegion(LatLngBounds currentRegion) {
    double lat = (currentRegion.northeast.latitude + currentRegion.southwest.latitude) / 2;
    double lon = (currentRegion.northeast.longitude + currentRegion.southwest.longitude) / 2;
    return LatLng(lat, lon);
  }
}