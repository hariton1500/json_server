import 'package:json_server/Models/cable.dart';
import 'package:json_server/Models/fosc.dart';
import 'package:json_server/Models/node.dart';

class Record {
  bool isDeleted = false;
}

class FoscRecord extends Record {
  Fosc? object;

  FoscRecord({required this.object});

  Map<String, dynamic> toJson() {
    return {'object': object, 'isDeleted': isDeleted};
  }

  FoscRecord.fromJson(Map<String, dynamic> json) {
    object = Fosc.fromJson(json['object']);
    isDeleted = json['isDeleted'] ?? false;
  }
}

class NodeRecord extends Record {
  Node? object;

  NodeRecord({required this.object});

  Map<String, dynamic> toJson() {
    return {'object': object, 'isDeleted': isDeleted};
  }

  NodeRecord.fromJson(Map<String, dynamic> json) {
    object = Node.fromJson(json['object']);
    isDeleted = json['isDeleted'] ?? false;
  }
}

class CableRecord extends Record {
  Cable? object;

  CableRecord({required this.object});

  Map<String, dynamic> toJson() {
    return {'object': object, 'isDeleted': isDeleted};
  }

  CableRecord.fromJson(Map<String, dynamic> json) {
    object = Cable.fromJson(json['object']);
    isDeleted = json['isDeleted'] ?? false;
  }
}
