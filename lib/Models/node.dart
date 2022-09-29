import 'package:latlong2/latlong.dart';

import 'activedevice.dart';
import 'cableend.dart';
import 'fosc.dart';

class Node {
  LatLng? location;
  List<ActiveDevice> equipments = [];
  List<CableEnd> cableEnds = [];
  String address = '';
  List<Connection> connections = [];
  String? key;

  Node({required this.address});
}