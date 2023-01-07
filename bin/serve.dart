import 'dart:convert';
import 'dart:io';

import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';
import 'package:serve/user.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

var users = [];

final path = Uri.directory(Directory.current.path).resolve("templates").toFilePath();

final env = Environment(
  globals: <String, Object?>{
    'now': () {
      final dt = DateTime.now().toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    },
  },
  loader: FileSystemLoader(),
  leftStripBlocks: true,
  trimBlocks: true,
);

Future<void> main(List<String> arguments) async {

  final app = Router();
  final apiRouter = Router();

  app.mount("/api", apiRouter);

  app.get("/", (request) {
    return Response.ok(env.getTemplate("index.html").render({"users": users.map((e) => e.toJson())}), headers: {'Content-Type': 'text/html'});
  });

  apiRouter.get("/users", (Request request) {
    return Response.ok(jsonEncode(users));
  });
  apiRouter.put("/users", (Request request) async {
    final Map<String, dynamic> jsonMap = jsonDecode(await request.readAsString());
    
    String username;
    String email;

    try {
      username = jsonMap["username"];
      email = jsonMap["email"];
    } catch (err) {
      return Response.badRequest(body: "Invalid request");
    }

    print(username);
    print(email);
    users.add(User(username, email));

    return Response.ok("User added");
  });

  final server = await io.serve(app, "localhost", 8080);
}
