import 'package:json_server/server.dart' as json_server;

void main(List<String> arguments) async {
  print('Json server runnning...');
  print(await json_server.run());
}
