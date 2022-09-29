import 'package:latlong2/latlong.dart';

import 'cableend.dart';

class Cable {
  CableEnd? end1, end2;
  List<LatLng> points = [];
  String? key;

  Cable({required this.end1, required this.end2});
}