class ActiveDevice {
  int id = -1;
  String ip = '';
  int ports = 0;
  String model = '';
  List<String> portComments = [];
  List<int> spliters = [];

  ActiveDevice(
      {required this.id,
      required this.ip,
      required this.ports,
      required this.model}) {
    portComments = List.filled(ports, '');
    spliters = List.filled(ports, 0);
  }

  ActiveDevice.fromJson(Map<String, dynamic> json) {
    //print('loading ActiveDevice from json=$json');
    id = json['id'] ?? -1;
    ip = json['ip'] as String;
    ports = json['ports'] as int;
    model = json['model'] as String;
    portComments = List.from(json['portComments']);
    spliters = List.from(json['spliters']);
  }

  String signature() {
    return '$ip:$ports:$model';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ip': ip,
      'ports': ports,
      'model': model,
      'portComments': portComments,
      'spliters': spliters
    };
  }
}
