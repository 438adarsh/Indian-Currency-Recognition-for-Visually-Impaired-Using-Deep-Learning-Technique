import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'displaypicture.dart';
import 'package:image_picker/image_picker.dart';


class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final picker = ImagePicker();
  late String path;


  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,

    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Assistant",
          style: TextStyle(fontSize: 26),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFF9933),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              child: Center(
                child: Container(
                  height: 450,
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Container(
        height: 100,
        width: 100,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () async {
              try {


                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                File imagefile = File(image.path);
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      imageFile: imagefile,
                    ),
                  ),
                );
              } catch (e) {
                print(e);
              }
            },
            child: const Icon(Icons.camera_alt),
            backgroundColor: Color(0xFF138808),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
