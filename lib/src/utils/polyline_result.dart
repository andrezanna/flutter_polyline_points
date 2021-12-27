import 'package:flutter_polyline_points/src/models/step.dart';

import '../../flutter_polyline_points.dart';

/// description:
/// project: flutter_polyline_points
/// @package: 
/// @author: dammyololade
/// created on: 13/05/2020
class PolylineResult {

  /// the api status retuned from google api
  ///
  /// returns OK if the api call is successful
  String? status;

  /// list of decoded points
  List<PointLatLng> points;
  List<Step?>? info;

  /// the error message returned from google, if none, the result will be empty
  String? errorMessage;
  String? time;
  String? distance;

  PolylineResult({this.status, this.points = const [], this.errorMessage = "",this.info,this.time,this.distance});


}