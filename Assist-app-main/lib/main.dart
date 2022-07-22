import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'takepicture.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: new ThemeData(scaffoldBackgroundColor: Colors.lightBlue.shade100),
    home: TakePictureScreen(
      camera: firstCamera,
    ), 
  ));
}
