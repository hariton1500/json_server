import 'package:latlong2/latlong.dart';

class Cable {
  String end1 = '', end2 = '';
  List<LatLng> points = [];
  String? key;

  Cable({required this.end1, required this.end2});

  Cable.fromJson(Map<String, dynamic> json) {
    end1 = json['end1'];
    end2 = json['end2'];
    try {
      points =
          List.from(json['points']).map((x) => LatLng.fromJson(x)).toList();
    } catch (e) {
      print(e);
    }
    key = json['key'];
  }

  String? parseEndString(String end) {
    try {
      List<String> data = end.split(':');
      switch (data[0].toLowerCase()) {
        case 'fosc':
          return 'fosc:' + data[1];
        case 'node':
          return 'node' + data[1];
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Map<String, dynamic> toJson() =>
      {'end1': end1, 'end2': end2, 'key': key, 'points': points};
}
