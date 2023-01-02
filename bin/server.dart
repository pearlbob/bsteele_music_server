import 'dart:developer';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

// import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

// // Configure routes.
// final _router = Router()
//   ..get('/', _rootHandler)
//   ..get('/echo/<message>', _echoHandler);
//
// Response _rootHandler(Request req) {
//   return Response.ok('Hello, World!\n');
// }
//
// Response _echoHandler(Request request) {
//   final message = request.params['message'];
//   return Response.ok('$message\n');
// }

void _appLogger(String msg, bool isError) {
  if (isError) {
    print('[ERROR] $msg');
  } else {
    print('my logger: "$msg"');
  }
}

void main(List<String> args) async {
  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8008');

  // // Use any available host or container IP (usually `0.0.0.0`).
  // final ip = InternetAddress.anyIPv4;
  //
  // // Configure a pipeline that logs requests.
  // final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
  //

  // final server = await serve(handler, ip, port);
  // print('Server listening on port ${server.port}');

  var handler = webSocketHandler((webSocket) async {
    webSocket.stream.listen((message) {
      webSocket.sink.add("echo $message");
      print('heard message: $message');
    });
  });

  // final handler = const shelf.Pipeline()
  //     .addMiddleware(corsHeaders())
  //     .addMiddleware(shelf.logRequests(
  //     logger: (message, isError) =>
  //         _logRequest(message, isError: isError)))
  //     .addHandler((req) async {
  //   final res = await Router().call(req);
  //   return res;
  // });

  // Configure a pipeline that logs requests.
  final socketServer = const Pipeline().addMiddleware(logRequests()).addHandler(handler);

  String wsUrl = '';
  await shelf_io.serve(socketServer, 'localhost', port).then((server) async {
    wsUrl = 'ws://${server.address.host}:${server.port}';
    print('Serving at $wsUrl');
  });

  //  test
  await Future.delayed(Duration(seconds: 1));

  print('client at $wsUrl');
  var socket = await WebSocket.connect(wsUrl);
  socket.listen((event) {
    print('event: ${event.runtimeType}: "$event"');
  }, onError: (Object error, StackTrace stackTrace) {
    print('onError: "$error"');
  }, onDone: () {
    print('onDone:');
  }, cancelOnError: false);
  socket.add('Hello, bob');
  socket.add('message 2');
  socket.add('message 3');

  await Future.delayed(Duration(seconds: 2));
  await socket.close();
  await Future.delayed(Duration(seconds: 2));
  exit(0);
}
