import 'package:latlong2/latlong.dart';

import '../Helpers/fibers.dart';

class CableEnd {
  int id = -1;
  int sideIndex = 0;
  String direction = '';
  int fibersNumber = 0;
  String? colorScheme;
  List<String> fiberComments = [];
  //List<int> withSpliter = [];
  Map<int, double> fiberPosY = {};
  List<int> spliters = [];
  LatLng? location;
  //Function callback = (Object asd) {};

  CableEnd(
      {required this.id,
      required this.fibersNumber,
      required this.direction,
      required this.sideIndex,
      required this.colorScheme}) {
    fiberComments = List.filled(fibersNumber, '');
    spliters = List.filled(fibersNumber, 0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'direction': direction,
        'sideIndex': sideIndex,
        'fibersNumber': fibersNumber,
        'colorScheme': colorScheme,
        'fiberComments': fiberComments,
        'spliter': spliters,
        'location': location?.toJson(),
      };

  CableEnd.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    direction = json["direction"];
    sideIndex = json["sideIndex"];
    fibersNumber = json["fibersNumber"];
    colorScheme = json['colorScheme'] ?? fiberColors.keys.first;
    fiberComments = List.castFrom<dynamic, String>(json['fiberComments']);
    spliters = json['spliters'] ?? List.filled(fibersNumber, 0);
    location =
        json['location'] != null ? LatLng.fromJson(json['location']) : null;
  }



}