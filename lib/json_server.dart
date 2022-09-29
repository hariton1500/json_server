import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'Models/cable.dart';
import 'Models/data.dart';
import 'Models/fosc.dart';
import 'Models/node.dart';

Future<String> run() async {
  List<Fosc> fileFoscsContent = [];
  List<Node> fileNodesContent = [];
  List<Cable> fileCablesContent = [];
  HttpServer server;

  final targetFoscsFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'dataFoscs.json'));
  final targetNodesFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'dataNodes.json'));
  final targetCablesFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'dataCables.json'));

  if (await targetFoscsFile.exists()) {
    print('Serving data from $targetFoscsFile');
    fileFoscsContent =
        (jsonDecode(await targetFoscsFile.readAsString()) as List)
            .map((e) => Fosc.fromJson(e))
            .toList();
  } else {
    print("$targetFoscsFile doesn't exists, nothing to load");
  }

  if (await targetNodesFile.exists()) {
    print('Serving data from $targetNodesFile');
    fileNodesContent =
        (jsonDecode(await targetNodesFile.readAsString()) as List)
            .map((e) => Node.fromJson(e))
            .toList();
  } else {
    print("$targetNodesFile doesn't exists, nothing to load");
  }

  if (await targetCablesFile.exists()) {
    print('Serving data from $targetCablesFile');
    fileCablesContent =
        (jsonDecode(await targetCablesFile.readAsString()) as List)
            .map((e) => Cable.fromJson(e))
            .toList();
  } else {
    print("$targetCablesFile doesn't exists, nothing to load");
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

    if (req.uri.path.startsWith('/fosc/')) {
      switch (req.requestedUri.queryParameters.keys.first) {
        case 'list':
          print('listing foscs=$fileFoscsContent');
          req.response
              .writeAll(fileFoscsContent.map((e) => json.encode(e)), '\n');
          await req.response.close();
          break;
        case 'add':
          print('adding new fosc');
          fileFoscsContent.add(Fosc.fromJson(
              json.decode(Utf8Decoder().convert(await req.last))));
          targetFoscsFile.writeAsString(json.encode(fileFoscsContent));
          break;
        case 'put':
          String jsonString = '';
          try {
            print(
                'putting fosc with key=${req.requestedUri.queryParameters['key']}');
            jsonString = Utf8Decoder().convert(await req.last);
            fileFoscsContent[fileFoscsContent.indexWhere((fosc) =>
                    fosc.key == req.requestedUri.queryParameters['key'])] =
                Fosc.fromJson(json.decode(jsonString));
            targetFoscsFile.writeAsString(json.encode(fileFoscsContent));
          } catch (e) {
            print('fosc was not found with that key');
            print('adding new fosc');
            fileFoscsContent.add(Fosc.fromJson(json.decode(jsonString)));
            targetFoscsFile.writeAsString(json.encode(fileFoscsContent));
          }
          break;
      }
    }

    if (req.uri.path.startsWith('/node/')) {
      switch (req.requestedUri.queryParameters.keys.first) {
        case 'list':
          print('listing nodes');
          req.response
              .writeAll(fileNodesContent.map((e) => json.encode(e)), '\n');
          await req.response.close();
          break;
        case 'add':
          print('adding new node');
          fileNodesContent.add(Node.fromJson(
              json.decode(Utf8Decoder().convert(await req.last))));
          targetNodesFile.writeAsString(json.encode(fileNodesContent));
          break;
        case 'put':
          String jsonString = '';
          try {
            print(
                'putting node with key=${req.requestedUri.queryParameters['key']}');
            jsonString = Utf8Decoder().convert(await req.last);
            fileNodesContent[fileNodesContent.indexWhere((node) =>
                    node.key == req.requestedUri.queryParameters['key'])] =
                Node.fromJson(json.decode(jsonString));
            targetNodesFile.writeAsString(json.encode(fileNodesContent));
          } catch (e) {
            print('node was not found with that key');
            print('adding new node');
            fileNodesContent.add(Node.fromJson(json.decode(jsonString)));
            targetNodesFile.writeAsString(json.encode(fileNodesContent));
          }
          break;
      }
    }

    if (req.uri.path.startsWith('/cable/')) {
      print(req.requestedUri.queryParameters);
      switch (req.requestedUri.queryParameters.keys.first) {
        case 'list':
          print('listing cables');
          req.response
              .writeAll(fileCablesContent.map((e) => json.encode(e)), '\n');
          await req.response.close();
          break;
        case 'add':
          print('adding new cablle');
          fileCablesContent.add(Cable.fromJson(
              json.decode(Utf8Decoder().convert(await req.last))));
          targetCablesFile.writeAsString(json.encode(fileCablesContent));
          req.response.close();
          break;
        case 'put':
          String jsonString = '';
          try {
            print(
                'putting fosc with key=${req.requestedUri.queryParameters['key']}');
            jsonString = Utf8Decoder().convert(await req.last);
            fileCablesContent[fileCablesContent.indexWhere((cable) =>
                    cable.key == req.requestedUri.queryParameters['key'])] =
                Cable.fromJson(json.decode(jsonString));
            targetCablesFile.writeAsString(json.encode(fileCablesContent));
          } catch (e) {
            print('cable was not found with that key');
            print('adding new cable');
            fileCablesContent.add(Cable.fromJson(json.decode(jsonString)));
            targetCablesFile.writeAsString(json.encode(fileCablesContent));
          }
          break;
      }
    }
    /*
    try {
      final offset =
          int.parse(req.requestedUri.queryParameters['offset'] ?? '0');
      final pageSize =
          int.parse(req.requestedUri.queryParameters['pageSize'] ?? '10');
      final sortIndex =
          int.parse(req.requestedUri.queryParameters['sortIndex'] ?? '1');
      final sortAsc =
          int.parse(req.requestedUri.queryParameters['sortAsc'] ?? '1') == 1;

      //fileFoscsContent.sort((a, b) => sortFoscs(a, b, sortIndex, sortAsc));
      req.response.write(
        jsonEncode(
          ResponseModel(
            fileFoscsContent.length,
            fileFoscsContent.skip(offset).take(pageSize).toList(),
          ),
        ),
      );
    } catch (e) {
      print('Something went wrong: $e');
      req.response.statusCode = HttpStatus.internalServerError;
    }
    await req.response.close();*/
  }
  return '123';
}
