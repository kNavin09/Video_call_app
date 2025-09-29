import 'package:flutter/material.dart';
import 'package:hipster_assignment/data/auth_service.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'core/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appDocumentDir = await getApplicationDocumentsDirectory();

  Hive.init(appDocumentDir.path);
  await Hive.openBox('authBox');
  bool loggedIn = await AuthService.isLoggedIn();

  runApp(MyApp(loggedIn: loggedIn));
}
