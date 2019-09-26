import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_geolocation/src/blocs/home_bloc.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeBloc bloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    bloc.checkPermissionLocal();
    bloc.createMarkers();
    bloc.createPolygons();
    bloc.createPolylines();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapas e Geolocalização'
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: bloc.checkPermissionLocalIsLoadingFetcher,
        builder: (context, AsyncSnapshot<bool> isLoadingObject) {
          if (isLoadingObject.hasData && !isLoadingObject.data) {
            return StreamBuilder(
              stream: bloc.mapTypeFetcher,
              builder: (context, AsyncSnapshot<MapType> mapTypeObject) {
                return StreamBuilder(
                  stream: bloc.markersFetcher,
                  builder: (context, AsyncSnapshot<Set<Marker>> markersObject) {
                    return GoogleMap(
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      mapType: mapTypeObject.data ?? bloc.mapType,
                      initialCameraPosition: bloc.currentPosition ?? bloc.kGooglePlex,
                      markers: markersObject.data ?? bloc.markers,
                      polygons: bloc.polygons,
                      polylines: bloc.polylines,
                      onMapCreated: (GoogleMapController controller) {
                        bloc.controller.complete(controller);
                      },
                    );
                  },
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: FloatingActionButton(
                    onPressed: () => bloc.moveCamera(),
                    tooltip: 'Movimentar Câmera',
                    child: Icon(Icons.camera),
                  )
                )
              ],
            ),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: () { 
                    bloc.changeVisualization();
                    _showAlertVisualization(bloc.mapType);
                  },
                  tooltip: 'Alterar visualização',
                  child: Icon(Icons.remove_red_eye),
                ),

                SizedBox(width: 10),

                FloatingActionButton(
                  tooltip: 'To the lake!',
                  onPressed: () => bloc.goToTheLake(),
                  child: Icon(Icons.directions_boat),
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  void _showAlertVisualization(MapType mapType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            mapType.toString()
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK'
              ),
            )
          ],
        );
      }
    );
  }
}