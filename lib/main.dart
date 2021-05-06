import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading;
  File _image;
  List _output;

  @override
  void initState() {
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  chooseImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = File(image.path);
    });
    runModelOnImage();
  }

  Future<String> loadModel() async {
    return await Tflite.loadModel(
        model: 'assets/model/fm.tflite', labels: 'assets/model/labels.txt');
  }

  runModelOnImage() async {
    var output = await Tflite.runModelOnImage(
        path: _image.path,
        numResults: 2,
        imageMean: 0.0,
        imageStd: 255.0,
        threshold: 0.5);
    print(output);
    setState(() {
      _isLoading = false;
      _output = output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Gender Classification',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Column(
                children: [
                  _image == null ? Container() : Image.file(_image),
                  SizedBox(
                    height: 16,
                  ),
                  _output == null ? Text('') : Text('${_output[0]["label"]}')
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(
          Icons.camera,
          size: 40,
        ),
        onPressed: () {
          chooseImage();
        },
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
