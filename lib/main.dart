import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as P;
import 'package:connectivity/connectivity.dart';

//Image && File Plugin
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

//Firebase Storage Plugin
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File sampleImage;
  File sampleFile;
  Map<String, String> filePaths;
  File _cachedFile;
  String _path;
  String fname;
  String nD;

//  network cennectivity detection.
//  @override
//  initState(){
//    super.initState();
//    Future<void> networkDetection() async {
//      var connectivityResult = await (Connectivity().checkConnectivity());
//      if (connectivityResult == ConnectivityResult.mobile) {
//        setState(() {
//          nD = "*************** UAV is online :)";
//        });
//      } else if (connectivityResult == ConnectivityResult.wifi) {
//        setState(() {
//          nD = "*************** SMARS is OFFLINE :(";
//        });
//      }
//    }
//    networkDetection().then((s){
//      print("///////////////// $nD");
//    });
//
//
//  }


  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }

  Future getFile() async {
    //File file = await FilePicker.getFile(type: FileType.ANY);
    Map<String, String> tempList = await FilePicker.getMultiFilePath();

    print('#################  $tempList ############ ${tempList.length}');
    print('@@@@@@@@@@@@@@@@@@@@@@ ${tempList.values.toList()[0]}');

    setState(() {
      filePaths = tempList;
    });
  }

  static var httpClient = new HttpClient();

  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ $dir');
    File file = new File('/storage/emulated/0/Download/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  String getFileName() {
    var now = new DateTime.now();
    return now.hashCode.toString();
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Image Upload'),
        centerTitle: true,
      ),
      body: new Center(
        //child: sampleImage == null ? Text('Select an image') : enableUpload(),
        child: enableUpload(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: new Icon(Icons.add),
      ), //// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          //Image.file(sampleImage, height: 300.0, width: 300.0),
          RaisedButton(
            elevation: 7.0,
            child: Text('Upload Image'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              final StorageReference firebaseStorageRef = FirebaseStorage
                  .instance
                  .ref()
                  .child('${P.basename(sampleImage.path)}.jpg');
              final StorageUploadTask task =
                  firebaseStorageRef.putFile(sampleImage);
            },
          ),
          RaisedButton(
            padding: EdgeInsets.only(top: 10.0),
            elevation: 7.0,
            child: Text('Select Files'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              getFile();
            },
          ),
          RaisedButton(
            padding: EdgeInsets.only(top: 10.0),
            elevation: 7.0,
            child: Text('Upload Files'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () async {
              File t;

              DocumentReference documentReference;

              for (int i = 0; i < filePaths.length; i++) {
                String tempname = getFileName();
                t = new File(filePaths.values.toList()[i]);
                //final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('${P.basename(t.path)}');
                final StorageReference firebaseStorageRef =
                    FirebaseStorage.instance.ref().child('$tempname');
                final StorageUploadTask task = firebaseStorageRef.putFile(t);

                var dowurl = await (await task.onComplete).ref.getDownloadURL();
                String url = dowurl.toString();


                print("@@@@@@@@@@@@UURRLL@@@@@@@@@@@@@@@@ $url");
                print("@@@@@@@@@@@@@@@FILEFILE@@@@@@@@@@@@@ ${getFileName()}");

                // firebase collection store
                documentReference = Firestore.instance
                    .collection("Files")
                    .document('$tempname');
                Map<String, dynamic> metaData = {
                  "Encoded": tempname,
                  "OrgName": P.basename(t.path),
                  "Link": url,
                  "Approve": false,
                };
                documentReference.setData(metaData);
                print('@#@#@#@#@#@#@#@#@#@#@#@#@#@# ${task.onComplete.toString()}');
                              }
            },
          ),
          RaisedButton(
            padding: EdgeInsets.only(top: 10.0),
            elevation: 7.0,
            child: Text('Download Files'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () async {
              _downloadFile(
                  'https://firebasestorage.googleapis.com/v0/b/fbup-65e1c.appspot.com/o/CONVOCATION.pdf?alt=media&token=3996798f-fb9f-4457-88ab-53fbfb4fa26d',
                  'test.pdf');
            },
          ),
          Text("Done With $fname"),
        ],
      ),
    );
  }

}

// #################################################################
//
//import 'package:flutter/material.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
//
//
//void main() => runApp(new MyApp());
//
//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
//      title: 'Flutter Demo',
//      theme: new ThemeData(
//        primarySwatch: Colors.blue,
//      ),
//      home: new MyHomePage(title: 'Flutter Demo Home Page'),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//  MyHomePage({Key key, this.title}) : super(key: key);
//
//  final String title;
//
//  @override
//  _MyHomePageState createState() => new _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      _counter++;
//    });
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
//    _firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) {
//        print('on message $message');
//      },
//      onResume: (Map<String, dynamic> message) {
//        print('on resume $message');
//      },
//      onLaunch: (Map<String, dynamic> message) {
//        print('on launch $message');
//      },
//    );
//    _firebaseMessaging.getToken().then((token){
//      print(token);
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      appBar: new AppBar(
//        title: new Text(widget.title),
//      ),
//      body: new Center(
//        child: new Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            new Text(
//              'You have pushed the button this many times:',
//            ),
//            new Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.display1,
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: new FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: new Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );
//  }
//}
//######################################################################
//
