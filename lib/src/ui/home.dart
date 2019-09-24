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
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: bloc.mapTypeFetcher,
        builder: (context, AsyncSnapshot<MapType> snapshot) {
          return GoogleMap(
            mapType: snapshot.data ?? bloc.mapType,
            initialCameraPosition: bloc.kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              bloc.controller.complete(controller);
            },
          );
        },
      ),
      floatingActionButton: Row(
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