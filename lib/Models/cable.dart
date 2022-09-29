import 'package:latlong2/latlong.dart';

import 'cableend.dart';

class Cable {
  CableEnd? end1, end2;
  List<LatLng> points = [];
  String? key;

  Cable({required this.end1, required this.end2});

  Cable.fromJson(Map<String, dynamic> json) {
    end1 = CableEnd.fromJson(json['end1']);
    end2 = CableEnd.fromJson(json['end2']);
    try {
      points =
          List.from(json['points']).map((x) => LatLng.fromJson(x)).toList();
    } catch (e) {
      print(e);
    }
    key = json['key'];
  }

  Map<String, dynamic> toJson() =>
      {'end1': end1, 'end2': end2, 'key': key, 'points': points};
}
