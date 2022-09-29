import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'Helpers/sort.dart';
import 'Models/cable.dart';
import 'Models/data.dart';
import 'Models/fosc.dart';
import 'Models/node.dart';

run() async {
  List<Fosc> fileFoscsContent = [];
  List<Node> fileNodesContent = [];
  List<Cable> fileCablesContent = [];
  HttpServer server;

  final targetFile = File(path.join(path.dirname(Platform.script.toFilePath()), 'dataFoscs.json'));

  if (await targetFile.exists()) {
    print('Serving data from $targetFile');
    fileFoscsContent = (jsonDecode(await targetFile.readAsString()) as List<dynamic>)
        .map((e) => Fosc.fromJson(e))
        .toList();
  } else {
    print("$targetFile doesn't exists, stopping");
    exit(-1);
  }
  try {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 4044);
  } catch (e) {
    print("Couldn't bind to port 4044: $e");
    exit(-1);
  }
  print('Listening on http://${server.address.address}:${server.port}/');

  await for (HttpRequest req in server) {
    req.response.headers.contentType = ContentType.json;
    //CORS Header, so the anybody can use this
    req.response.headers.add(
      'Access-Control-Allow-Origin',
      '*',
      preserveHeaderCase: true,
    );

    try {
      final offset =
          int.parse(req.requestedUri.queryParameters['offset'] ?? '0');
      final pageSize =
          int.parse(req.requestedUri.queryParameters['pageSize'] ?? '10');
      final sortIndex =
          int.parse(req.requestedUri.queryParameters['sortIndex'] ?? '1');
      final sortAsc =
          int.parse(req.requestedUri.queryParameters['sortAsc'] ?? '1') == 1;

      fileFoscsContent.sort((a, b) => sortFoscs(a, b, sortIndex, sortAsc));
      req.response.write(
        jsonEncode(
          ResponseModel(
            fileFoscsContent!.length,
            fileFoscsContent.skip(offset).take(pageSize).toList(),
          ),
        ),
      );
    } catch (e) {
      print('Something went wrong: $e');
      req.response.statusCode = HttpStatus.internalServerError;
    }
    await req.response.close();
  }

}