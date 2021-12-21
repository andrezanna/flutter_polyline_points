import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_polyline_points/src/models/step.dart' as stp;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyline example',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  // double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  // double _destLatitude = 6.849660, _destLongitude = 3.648190;
  double _originLatitude = 45.43486265055448,
      _originLongitude = 12.349915618229982;
  double _destLatitude = 45.42945260654147, _destLongitude = 12.343274567565832;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "YOUR API KEY";
  Widget bottom = Container(height: 150,);
  @override
  void initState() {
    super.initState();

    loadMarkersAndPolyline();

  }

  loadMarkersAndPolyline(){
    markers.clear();
  polylines.clear();
  polylineCoordinates.clear();
    Widget bottom = Container(height: 150,);

    /// origin marker
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          bottomSheet: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: bottom,
          ),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(_originLatitude, _originLongitude), zoom: 15),
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: _onMapCreated,
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
            onTap: (dest){
              _destLatitude=dest.latitude;
              _destLongitude=dest.longitude;
              loadMarkersAndPolyline();

            },
            onLongPress: (start){
              _originLatitude=start.latitude;
              _originLongitude=start.longitude;
              loadMarkersAndPolyline();

            },
          )),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(_originLatitude, _originLongitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.transit,
        language: "it");
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    if (result.info.isNotEmpty) {
      bottom = Container(
          height: 300,
          child: Column(
            children: [
              Text("Prevede transiti a pagamento:"),
              ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (c, index) =>
                    TransitInfoListWidget(step: result.info[index],index:index),
                itemCount: result.info.length,
              ),
            ],
          ));
      setState(() {});
    }
    _addPolyLine();
  }
}

class TransitInfoListWidget extends StatelessWidget {
  final stp.Step step;
  final int index;

  const TransitInfoListWidget({Key key, this.step, this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print(step.details["departure_time"]["text"]);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          InkWell(onTap:(){launch(step.details["line"]["agencies"][0]["url"]);},child:Icon(Icons.info)),
          Expanded(
            child: Column(
              children: [ListTile(visualDensity: VisualDensity(horizontal: 0, vertical: -4),title: Text(step.instruction),contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 12.0)),
                ListTile(    visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    leading: Text("Orario"),title: Text(step.details["departure_time"]["text"]),contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 12.0),),
                ListTile(    visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    leading: Text("Linea"),title: Text(step.details["headsign"]),contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 12.0)),
                ],
            ),
          ),
          Image.network("https:"+step.details["line"]["vehicle"]["icon"])
        ],
      ),
    );
  }
}
