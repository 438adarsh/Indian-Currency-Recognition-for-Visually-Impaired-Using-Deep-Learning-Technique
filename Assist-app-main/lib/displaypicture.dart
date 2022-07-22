import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite/tflite.dart';

class DisplayPictureScreen extends StatefulWidget {
  final File imageFile;
  const DisplayPictureScreen({Key? key, required this.imageFile})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late FlutterTts flutterTts;
  bool isPlaying = false;
  bool isImageLoaded = false;
  late List<dynamic>? _result;
  String _finalname = "";
  String _name = "";
  String _confidence = "";
  late File pickedImage;

  getStarted() async {
    setState(() {
      pickedImage = widget.imageFile;
      isImageLoaded = true;
    });
    applyModelOnImage(pickedImage);
  }

  loadMyModel() async {
    var resultant = await Tflite.loadModel(
        labels: "assets/labels.txt", model: "assets/HandCashDetection.tflite");
    print("Result after loading model: $resultant");
  }

  applyModelOnImage(File file) async {
    List<dynamic>? res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 7,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _result = res;
      _name = _result![0]["label"];
      _confidence = _result != null
          ? (_result![0]['confidence'] * 100.0).toString().substring(0, 2) + "%"
          : "";

      switch (_name) {
        case '50':
          _finalname = 'Rs 50';
          break;
        case '100':
          _finalname = 'Rs 100';
          break;
        case '10':
          _finalname = 'Rs 10';
          break;
        case '20':
          _finalname = 'Rs 20';
          break;
        case 'back':
          _finalname = 'Background';
          break;
        case '2000':
          _finalname = 'Rs 2000';
          break;
        case '500':
          _finalname = 'Rs 500';
          break;
        case '200':
          _finalname = 'Rs 200';
          break;
        default:
          _finalname = _name;
          break;
      }

      speechSettings1();
      isPlaying ? _stop() : _speak(_finalname);
    });
  }

  initTts() {
    flutterTts = FlutterTts();
    setTtsLanguage();

    flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    flutterTts.setErrorHandler((err) {
      setState(() {
        print('error occured: ' + err);
        isPlaying = false;
      });
    });
  }

  void setTtsLanguage() async {
    await flutterTts.setLanguage("en-US");
  }

  void speechSettings1() {
    flutterTts.setPitch(1.5);
    flutterTts.setSpeechRate(.6);
  }

  Future _speak(String text) async {
    if (text.isNotEmpty) {
      var result = await flutterTts.speak(text);
      if (result == 1) {
        setState(() {
          isPlaying = true;
        });
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initTts();
    loadMyModel().then((val) {
      setState(() {});
    });
    getStarted();
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
    flutterTts.stop();
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
        backgroundColor: Color(0xFF138808),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
        ),
        child: Column(
          children: <Widget>[
            isImageLoaded
                ? Center(
                    child: Container(
                      margin: EdgeInsets.all(40),
                      height: 400,
                      width: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File(pickedImage.path)),
                            fit: BoxFit.contain),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              height: 30,
            ),
            Text(
              "NAME: $_finalname",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "CONFIDENCE: $_confidence",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 100,
        width: 100,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.refresh),
            backgroundColor: Color(0xFF138808),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
