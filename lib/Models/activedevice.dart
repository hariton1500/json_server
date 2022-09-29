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
}