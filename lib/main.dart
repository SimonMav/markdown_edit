import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Some title 1",
      home: Home(
        storage: Storage(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final Storage storage;

  Home({Key key, @required this.storage}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  TextEditingController controller = TextEditingController();
  String state;
  Future<Directory> _appDocDir;

  @override
  void initState() {
    super.initState();
    widget.storage.readData().then((String value) {
      setState(() {
        state = value;
      });
    });
  }

  Future<File> writeData() async {
    setState(() {
      state = controller.text;
      controller.text = '';
    });

    return widget.storage.writeData(state);
  }

  void getAppDirectory() {
    setState(() {
      _appDocDir = getApplicationDocumentsDirectory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(tabs: [
              Tab(icon: Icon(Icons.remove_red_eye)),
              Tab(icon: Icon(Icons.edit)),
            ]),
            title: Text('# a simple markdown editor'),
          ),
          body: TabBarView(children: [
            Center(
                child: Markdown(
              data: '$state',
            )),
            Center(
              child: Column(
                children: <Widget>[
                  Divider(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Card(
                          child: Text(
                              '${state ?? "Please create or fill a file!"}'),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  TextFormField(
                    ///A TextFormField cannot accept an initialValue AND a controller
                    //initialValue: '$state',
                    controller: controller,
                  ),
                  RaisedButton(
                    onPressed: writeData,
                    child: Text('Write to file'),
                  ),
                  RaisedButton(
                    child: Text('get DIR path'),
                    onPressed: getAppDirectory,
                  ),
                  FutureBuilder<Directory>(
                    future: _appDocDir,
                    builder: (BuildContext context,
                        AsyncSnapshot<Directory> snapshot) {
                      Text text = Text('');
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          text = Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          text = Text('Path: ${snapshot.data.path}');
                        } else {
                          text = Text('Something weird happened!');
                        }
                      }
                      return new Container(
                        child: text,
                      );
                    },
                  )
                ],
              ),
            ),
          ]),
        ));
  }
}

class Storage {
  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get userFile async {
    FlutterDocumentPickerParams params =
        FlutterDocumentPickerParams(allowedFileExtensions: ['txt', 'md']);

    final path = await FlutterDocumentPicker.openDocument(params: params);
    return File('$path');
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/test.txt');
  }

  Future<String> readData() async {
    try {
      final file = await userFile;
      String body = await file.readAsString();
      return body;
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> writeData(String data) async {
    final file = await localFile;
    return file.writeAsString('$data');
  }
}

///----------- Markdown Viewer -----------///
/// Kommt auch noch...