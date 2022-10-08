import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'Models/cable.dart';
import 'Models/fosc.dart';
import 'Models/node.dart';
import 'Models/records.dart';
import 'Models/user.dart';

import 'Helpers/md5.dart';

Future<String> run() async {
  Map<String, User> users = {};
  Map<String, FoscRecord> fileFoscsContent = {};
  Map<String, NodeRecord> fileNodesContent = {};
  Map<String, CableRecord> fileCablesContent = {};

  HttpServer server;

  final usersFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'users.json'));
  final targetFoscsFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'dataFoscs.json'));
  final targetNodesFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'dataNodes.json'));
  final targetCablesFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'dataCables.json'));

  if (await usersFile.exists()) {
    users = (jsonDecode(await usersFile.readAsString()) as Map)
        .map((key, value) =>
            MapEntry<String, User>(key, User.fromJson(value)));
  } else {
    print("$targetFoscsFile doesn't exists, nothing to load");
  }

  if (await targetFoscsFile.exists()) {
    print('Serving data from $targetFoscsFile');
    fileFoscsContent = (jsonDecode(await targetFoscsFile.readAsString()) as Map)
        .map((key, value) =>
            MapEntry<String, FoscRecord>(key, FoscRecord.fromJson(value)));
  } else {
    print("$targetFoscsFile doesn't exists, nothing to load");
  }

  if (await targetNodesFile.exists()) {
    print('Serving data from $targetNodesFile');
    fileNodesContent = (jsonDecode(await targetNodesFile.readAsString()) as Map)
        .map((key, value) =>
            MapEntry<String, NodeRecord>(key, NodeRecord.fromJson(value)));
  } else {
    print("$targetNodesFile doesn't exists, nothing to load");
  }

  if (await targetCablesFile.exists()) {
    print('Serving data from $targetCablesFile');
    fileCablesContent = (jsonDecode(await targetCablesFile.readAsString())
            as Map)
        .map((key, value) =>
            MapEntry<String, CableRecord>(key, CableRecord.fromJson(value)));
  } else {
    print("$targetCablesFile doesn't exists, nothing to load");
  }

  try {
    server = await HttpServer.bind(InternetAddress.anyIPv4, 4044);
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

    if (users[req.headers.value('login')]?.password == generateMd5(req.headers.value('password'))) {
      if (req.uri.path.startsWith('/fosc/')) {
        switch (req.requestedUri.queryParameters.keys.first) {
          case 'list':
            print(
                'foscs list requested from ${req.headers['host']} by ${req.headers['login']}');
            req.response.writeAll(
                fileFoscsContent.values
                    .where((element) => !element.isDeleted)
                    .map((e) => json.encode(e.object)),
                '\n');
            break;
          case 'add':
            if (users[req.headers.value('login')]?.access['create']) {
              print('adding new fosc');
              fileFoscsContent[req.requestedUri.queryParameters['key']!] =
                  (FoscRecord(
                      object: Fosc.fromJson(
                          json.decode(Utf8Decoder().convert(await req.last)))));
              targetFoscsFile.writeAsString(json.encode(fileFoscsContent));
            }
            break;
          case 'put':
            if (users[req.headers.value('login')]?.access['edit']) {
              print(
                  'putting fosc with key=${req.requestedUri.queryParameters['key']}');
              fileFoscsContent[req.requestedUri.queryParameters['key']!] =
                  (FoscRecord(
                      object: Fosc.fromJson(
                          json.decode(Utf8Decoder().convert(await req.last)))));
              targetFoscsFile.writeAsString(json.encode(fileFoscsContent));
            }
            break;
          case 'remove':
            if (users[req.headers.value('login')]?.access['remove']) {
              print(
                  'removing fosc with key=${req.requestedUri.queryParameters['key']}');
              fileFoscsContent[req.requestedUri.queryParameters['key']!]
                  ?.isDeleted = true;
              targetFoscsFile.writeAsString(json.encode(fileFoscsContent));
            }
            break;
        }
        //await req.response.close();
      }

      if (req.uri.path.startsWith('/node/')) {
        switch (req.requestedUri.queryParameters.keys.first) {
          case 'list':
            print(
                'nodes list requested from ${req.headers['host']} by ${req.headers['login']}');
            if (fileNodesContent.isNotEmpty) {
              req.response.writeAll(
                  fileNodesContent.values
                      .where((element) => !element.isDeleted)
                      .map((e) => json.encode(e.object)),
                  '\n');
              await req.response.close();
            }
            break;
          case 'add':
            if (users[req.headers.value('login')]?.access['create']) {
              print('adding new node');
              fileNodesContent[req.requestedUri.queryParameters['key']!] =
                  (NodeRecord(
                      object: Node.fromJson(
                          json.decode(Utf8Decoder().convert(await req.last)))));
              targetNodesFile.writeAsString(json.encode(fileNodesContent));
            }
            break;
          case 'put':
            if (users[req.headers.value('login')]?.access['edit']) {
              print(
                  'putting node with key=${req.requestedUri.queryParameters['key']}');
              fileNodesContent[req.requestedUri.queryParameters['key']!] =
                  (NodeRecord(
                      object: Node.fromJson(
                          json.decode(Utf8Decoder().convert(await req.last)))));
              targetNodesFile.writeAsString(json.encode(fileNodesContent));
            }
            break;
          case 'remove':
            if (users[req.headers.value('login')]?.access['remove']) {
              print(
                  'removing node with key=${req.requestedUri.queryParameters['key']}');
              fileNodesContent[req.requestedUri.queryParameters['key']!]
                  ?.isDeleted = true;
              targetNodesFile.writeAsString(json.encode(fileNodesContent));
            }
            break;
        }
      }

      if (req.uri.path.startsWith('/cable/')) {
        print(req.requestedUri.queryParameters);
        switch (req.requestedUri.queryParameters.keys.first) {
          case 'list':
            print(
                'cables list requested from ${req.headers['host']} by ${req.headers['login']}');
            req.response.writeAll(
                fileCablesContent.values
                    .where((element) => !element.isDeleted)
                    .map((e) => json.encode(e.object)),
                '\n');
            await req.response.close();
            break;
          case 'add':
            if (users[req.headers.value('login')]?.access['create']) {
              print('adding new cable');
              fileCablesContent[req.requestedUri.queryParameters['key']!] =
                  (CableRecord(
                      object: Cable.fromJson(
                          json.decode(Utf8Decoder().convert(await req.last)))));
              targetCablesFile.writeAsString(json.encode(fileCablesContent));
              req.response.close();
            }
            break;
          case 'put':
            if (users[req.headers.value('login')]?.access['edit']) {
              print(
                  'putting cable with key=${req.requestedUri.queryParameters['key']}');
              fileCablesContent[req.requestedUri.queryParameters['key']!] =
                  (CableRecord(
                      object: Cable.fromJson(
                          json.decode(Utf8Decoder().convert(await req.last)))));
              targetCablesFile.writeAsString(json.encode(fileCablesContent));
            }
            break;
          case 'remove':
            if (users[req.headers.value('login')]?.access['remove']) {
              print(
                  'removing cable with key=${req.requestedUri.queryParameters['key']}');
              fileCablesContent[req.requestedUri.queryParameters['key']!]
                  ?.isDeleted = true;
              targetCablesFile.writeAsString(json.encode(fileCablesContent));
            }
            break;
        }
      }
    } else {
      print('unauthorized');
    }
    //req.response.writeln('ok');
    req.response.close();
  }
  return 'done.';
}
