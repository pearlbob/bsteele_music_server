import 'dart:io';

// import 'package:shelf/shelf.dart';
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

void main(List<String> args) async {
  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8088');

  // // Use any available host or container IP (usually `0.0.0.0`).
  // final ip = InternetAddress.anyIPv4;
  //
  // // Configure a pipeline that logs requests.
  // final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
  //

  // final server = await serve(handler, ip, port);
  // print('Server listening on port ${server.port}');

  var handler = webSocketHandler((webSocket) {
    webSocket.stream.listen((message) {
      webSocket.sink.add("echo $message");
      print('heard message: $message');
    });
  });

  String wsUrl = '';
  await shelf_io.serve(handler, 'localhost', port).then((server) {
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
