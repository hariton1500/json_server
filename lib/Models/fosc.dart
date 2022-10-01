import 'package:latlong2/latlong.dart';

import 'cableend.dart';

class Connection {
  int cableIndex1, fiberNumber1, cableIndex2, fiberNumber2;
  Connection(
      {required this.cableIndex1,
      required this.fiberNumber1,
      required this.cableIndex2,
      required this.fiberNumber2});

  Map<String, dynamic> toJson() => {
        //'connectionData' : connectionData,
        'cableIndex1': cableIndex1,
        'cableIndex2': cableIndex2,
        'fiberNumber1': fiberNumber1,
        'fiberNumber2': fiberNumber2
      };
  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        cableIndex1: json["cableIndex1"],
        cableIndex2: json["cableIndex2"],
        fiberNumber1: json["fiberNumber1"],
        fiberNumber2: json["fiberNumber2"],
      );
}

class Fosc {
  String name = '';
  List<CableEnd> cableEnds = [];
  List<Connection> connections = [];
  LatLng? location;
  String? key;

  Fosc({
    required this.name,
    required this.cableEnds,
    required this.connections,
    this.location,
  });

  Fosc.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    cableEnds =
        List<CableEnd>.from(json['cables'].map((x) => CableEnd.fromJson(x)));
    connections = List<Connection>.from(
        json['connections'].map((x) => Connection.fromJson(x)));
    location = LatLng.fromJson(json['location']);
    key = json['key'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cables': cableEnds,
      'connections': connections,
      'location': location!.toJson(),
      'key': key
    };
  }
}
