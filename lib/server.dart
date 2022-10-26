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
  String adminpass = '';
  Map<String, User> users = {};
  Map<String, FoscRecord> fileFoscsContent = {};
  Map<String, NodeRecord> fileNodesContent = {};
  Map<String, CableRecord> fileCablesContent = {};

  HttpServer server;

  final editPageFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'html/edit.html'));
  final adminFile =
      File(path.join(path.dirname(Platform.script.toFilePath()), 'admin.json'));
  final usersPageFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'html/users.html'));
  final usersFile =
      File(path.join(path.dirname(Platform.script.toFilePath()), 'users.json'));
  final targetFoscsFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'dataFoscs.json'));
  final targetNodesFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'dataNodes.json'));
  final targetCablesFile = File(
      path.join(path.dirname(Platform.script.toFilePath()), 'dataCables.json'));

  if (await adminFile.exists()) {
    adminpass = jsonDecode(await adminFile.readAsString())['password'];
  }

  if (await usersFile.exists()) {
    users = (jsonDecode(await usersFile.readAsString()) as Map)
        .map((key, value) => MapEntry<String, User>(key, User.fromJson(value)));
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
    print(DateTime.now());
    req.response.headers.contentType = ContentType.json;
    //CORS Header, so the anybody can use this
    req.response.headers.add(
      'Access-Control-Allow-Origin',
      '*',
      preserveHeaderCase: true,
    );

    print(
        '[${req.connectionInfo?.remoteAddress.address}] -> ${req.uri.path} -> ${req.requestedUri.queryParameters}');

    if (req.uri.path == '/users' || req.uri.path == '/users/') {
      req.response.headers.contentType = ContentType.html;
      req.response.write(await usersPageFile.readAsString());
    }
    if (req.uri.path == '/edit.html') {
      req.response.headers.contentType = ContentType.html;
      req.response.write(await editPageFile.readAsString());
    }
    if (req.uri.path == '/users/list') {
      if (req.headers['adminpass'] != null &&
          generateMd5(req.headers.value('adminpass')) == adminpass) {
        print('Users: ${users}');
        req.response.headers.contentType = ContentType.json;
        req.response.write(await usersFile.readAsString());
      } else {
        print('admin unauthorized');
        req.response.write('-100');
      }
    }
    if (req.uri.path == '/users/del') {
      if (req.headers['adminpass'] != null &&
          generateMd5(req.headers.value('adminpass')) == adminpass) {
        if (req.requestedUri.queryParameters['user'] != null) {
          if (users[req.requestedUri.queryParameters['user']] != null) {
            users.remove(req.requestedUri.queryParameters['user']);
            usersFile.writeAsString(json.encode(users));
            req.response.write('0');
          } else {
            print('user ${req.requestedUri.queryParameters['user']} not exist');
            req.response.write('-2');
          }
        } else {
          req.response.write('-5');
        }
      } else {
        print('admin unauthorized');
        req.response.write('-100');
      }
    }
    if (req.uri.path == '/users/edit') {
      if (req.headers['adminpass'] != null &&
          generateMd5(req.headers.value('adminpass')) == adminpass) {
        if (req.requestedUri.queryParameters['user'] != null &&
            req.requestedUri.queryParameters['password'] != null &&
            req.requestedUri.queryParameters['access'] != null) {
          if (users[req.requestedUri.queryParameters['user']] != null) {
            bool userPermsCreate;
            bool userPermsEdit;
            bool userPermsRemove;
            bool userDisabled;
            req.requestedUri.queryParameters['access']![0] == "1"
                ? userPermsCreate = true
                : userPermsCreate = false;
            req.requestedUri.queryParameters['access']![1] == "1"
                ? userPermsEdit = true
                : userPermsEdit = false;
            req.requestedUri.queryParameters['access']![2] == "1"
                ? userPermsRemove = true
                : userPermsRemove = false;
            req.requestedUri.queryParameters['disabled']! == "1"
                ? userDisabled = true
                : userDisabled = false;
            users[req.requestedUri.queryParameters['user']]!.access['create'] =
                userPermsCreate;
            users[req.requestedUri.queryParameters['user']]!.access['edit'] =
                userPermsEdit;
            users[req.requestedUri.queryParameters['user']]!.access['remove'] =
                userPermsRemove;
            if (req.requestedUri.queryParameters['password'] != "") {
              users[req.requestedUri.queryParameters['user']]!.password =
                  generateMd5(req.requestedUri.queryParameters['password']);
            } else {
              print('keep previous password');
            }
            users[req.requestedUri.queryParameters['user']]!.disabled =
                userDisabled;
            if (req.requestedUri.queryParameters['login'] !=
                req.requestedUri.queryParameters['user']) {
              users[req.requestedUri.queryParameters['login']!] =
                  users[req.requestedUri.queryParameters['user']]!;
              users.remove(req.requestedUri.queryParameters['user']);
            }
            usersFile.writeAsString(json.encode(users));
            req.response.write('0');
          } else {
            print('user ${req.requestedUri.queryParameters['user']} not exist');
            req.response.write('-2');
          }
        } else {
          req.response.write('-5');
        }
      } else {
        print('admin unauthorized');
        req.response.write('-100');
      }
    }
    if (req.uri.path == '/users/add') {
      if (req.headers['adminpass'] != null &&
          generateMd5(req.headers.value('adminpass')) == adminpass) {
        if (req.requestedUri.queryParameters['login'] != null &&
            req.requestedUri.queryParameters['password'] != null &&
            req.requestedUri.queryParameters['access'] != null) {
          if (users[req.requestedUri.queryParameters['login']] == null) {
            bool newUserPermsCreate;
            bool newUserPermsEdit;
            bool newUserPermsRemove;
            req.requestedUri.queryParameters['access']![0] == "1"
                ? newUserPermsCreate = true
                : newUserPermsCreate = false;
            req.requestedUri.queryParameters['access']![1] == "1"
                ? newUserPermsEdit = true
                : newUserPermsEdit = false;
            req.requestedUri.queryParameters['access']![2] == "1"
                ? newUserPermsRemove = true
                : newUserPermsRemove = false;
            User newUser = User(
              password:
                  generateMd5(req.requestedUri.queryParameters['password']),
              newAccess: {
                'create': newUserPermsCreate,
                'edit': newUserPermsEdit,
                'remove': newUserPermsRemove
              },
              disabled: false,
            );
            users[req.requestedUri.queryParameters['login']!] = newUser;
            print('Users: ${users}');
            usersFile.writeAsString(json.encode(users));
            req.response.write('0');
          } else {
            print(
                'user ${req.requestedUri.queryParameters['user']} already exist');
            req.response.write('-1');
          }
        } else {
          req.response.write('-5');
        }
      } else {
        print('admin unauthorized');
        req.response.write('-100');
      }
    }

    if (req.headers['login'] != null &&
        req.headers['password'] != null &&
        users[req.headers.value('login')]?.disabled == false &&
        users[req.headers.value('login')]?.password ==
            generateMd5(req.headers.value('password'))) {
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
              /*
              fileCablesContent.values.forEach((element) {
                if (!element.isDeleted) {
                  if (element.object!.end1!.direction == fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.cableEnds[0].direction) {
                    element.object!.end1!.location = fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.location;
                    element.object!.points.first = fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.location!;
                  }
                  if (element.object!.end2!.direction == fileFoscsContent[req.requestedUri.queryParameters['key']!]!.object!.cableEnds[0].direction) {
                    element.object!.end2!.location = fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.location;
                    element.object!.points.last = fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.location!;
                  }
                }
              });
              targetCablesFile.writeAsString(json.encode(fileCablesContent));*/
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
              /*
              fileCablesContent.values.forEach((element) {
                if (!element.isDeleted) {
                  if (element.object!.end1!.direction == fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.cableEnds[0].direction) {
                    element.object!.end1!.location = fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.location;
                    element.object!.points.first = fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.location!;
                  }
                  if (element.object!.end2!.direction == fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.cableEnds[0].direction) {
                    element.object!.end2!.location = fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.location;
                    element.object!.points.last = fileFoscsContent[req.requestedUri.queryParameters['key']]!.object!.location!;
                  }
                }
              });
              targetCablesFile.writeAsString(json.encode(fileCablesContent));*/
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
      print('user unauthorized');
    }
    //req.response.writeln('ok');
    req.response.close();
  }
  return 'done.';
}
