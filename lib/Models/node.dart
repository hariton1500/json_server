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

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'location': location!.toJson(),
      'equipments': equipments,
      'cableEnds': cableEnds,
      'connections': connections,
      'key': key
    };
  }

  Node.fromJson(Map<String, dynamic> json) {
    location = LatLng.fromJson(json['location']);
    equipments = List.from(json['equipments'])
        .map((x) => ActiveDevice.fromJson(x))
        .toList();
    address = json['address'];
    cableEnds =
        List.from(json['cableEnds']).map((x) => CableEnd.fromJson(x)).toList();
    connections = List.from(json['connections']).map((e) {
      print(e);
      var side1 = e['connectionData'][0];
      var side2 = e['connectionData'][1];
      Object s1, s2;
      side1['side1'][0] == 'AD'
          ? s1 = equipments.firstWhere((x) => x.ip == side1['side1'][1])
          : s1 = cableEnds.firstWhere((x) => x.direction == side1['side1'][1]);
      side2['side2'][0] == 'AD'
          ? s2 = equipments.firstWhere((x) => x.ip == side2['side2'][1])
          : s2 = cableEnds.firstWhere((x) => x.direction == side2['side2'][1]);
      return Connection(
          connectionData: MapEntry(
              MapEntry(s1, side1['port']), MapEntry(s2, side2['port'])));
    }).toList();
    key = json['key'];
  }
}

class Connection {
  MapEntry<MapEntry<Object, int>, MapEntry<Object, int>>? connectionData;

  Connection({required this.connectionData});
  Connection.fromJson(Map<String, dynamic> json) {
    for (var connectionMap in json['connections']) {
      var side1 = connectionMap['connectionData'][0];
      var side2 = connectionMap['connectionData'][1];
      (side1['side1'] as Map<String, dynamic>).containsKey('AD')
          ? connectionData = MapEntry(
              MapEntry(
                  ActiveDevice.fromJson(side1['side1'] as Map<String, dynamic>),
                  side1['side1']['port'] as int),
              MapEntry(
                  ActiveDevice.fromJson(side2['side2'] as Map<String, dynamic>),
                  side2['side2']['port'] as int))
          : connectionData = MapEntry(
              MapEntry(
                  CableEnd.fromJson(side1['side1'] as Map<String, dynamic>),
                  side1['side1']['port'] as int),
              MapEntry(
                  CableEnd.fromJson(side2['side2'] as Map<String, dynamic>),
                  side2['side2']['port'] as int));
    }
  }

  Map<String, dynamic> toJson() {
    var side1 = MapEntry(
        connectionData!.key.key is ActiveDevice
            ? ['AD', (connectionData!.key.key as ActiveDevice).ip]
            : ['CE', (connectionData!.key.key as CableEnd).direction],
        connectionData!.key.value);
    var side2 = MapEntry(
        connectionData!.value.key is ActiveDevice
            ? ['AD', (connectionData!.value.key as ActiveDevice).ip]
            : ['CE', (connectionData!.value.key as CableEnd).direction],
        connectionData!.value.value);
    return {
      'connectionData': [
        {'side1': side1.key, 'port': side1.value},
        {'side2': side2.key, 'port': side2.value}
      ]
    };
  }
}
