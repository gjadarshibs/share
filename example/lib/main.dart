import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import 'image_previews.dart';


import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:typed_data';

void main() {
  runApp(DemoApp());
}

class DemoApp extends StatefulWidget {
  @override
  DemoAppState createState() => DemoAppState();
}

class DemoAppState extends State<DemoApp> {
  String text = '';
  String subject = '';
  List<String> imagePaths = [];
  static GlobalKey previewContainer = GlobalKey();

  ///method to take screenshot of the ticket and share it
  Future<void> shareTicket() async {
    try {
      RenderRepaintBoundary boundary =
          previewContainer.currentContext.findRenderObject();
      if (boundary.debugNeedsPaint) {
        Timer(Duration(seconds: 1), () => shareTicket());
        return null;
      }
      ui.Image image = await boundary.toImage();
      final directory = (await getExternalStorageDirectory()).path;
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      File imgFile = File('$directory/screenshot.png');
      await imgFile.writeAsBytes(pngBytes);
      final RenderBox box = context.findRenderObject();
      await Share.shareFiles(['$directory/screenshot.png'],
          subject: 'Sharing screenshot',
          text: 'This is your screenshot',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } on PlatformException catch (e) {
      debugPrint('Exception while sharing the screenshot:' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Plugin Demo',
      home: RepaintBoundary(
        key: previewContainer,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Share Plugin Demo'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Share text:',
                        hintText: 'Enter some text and/or link to share',
                      ),
                      maxLines: 2,
                      onChanged: (String value) => setState(() {
                        text = value;
                      }),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Share subject:',
                        hintText: 'Enter subject to share (optional)',
                      ),
                      maxLines: 2,
                      onChanged: (String value) => setState(() {
                        subject = value;
                      }),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 12.0)),
                    ImagePreviews(imagePaths, onDelete: _onDeleteImage),
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text("Add image"),
                      onTap: () async {
                        final imagePicker = ImagePicker();
                        final pickedFile = await imagePicker.getImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            imagePaths.add(pickedFile.path);
                          });
                        }
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(top: 12.0)),
                    Builder(
                      builder: (BuildContext context) {
                        return RaisedButton(
                          child: const Text('Share'),
                          onPressed: text.isEmpty && imagePaths.isEmpty
                              ? null
                              : () => _onShare(context),
                        );
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(top: 12.0)),
                    Builder(
                      builder: (BuildContext context) {
                        return RaisedButton(
                          child: const Text('Share With Empty Origin'),
                          onPressed: () => _onShareWithEmptyOrigin(context),
                        );
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(top: 12.0)),
                    RaisedButton(
                        child: const Text('Share screenshot of the page'),
                        onPressed: () {
                          shareTicket();
                        })
                  ],
                ),
              ),
            )),
      ),
    );
  }

  _onDeleteImage(int position) {
    setState(() {
      imagePaths.removeAt(position);
    });
  }

  _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the RaisedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The RaisedButton's RenderObject
    // has its position and size after it's built.
    final RenderBox box = context.findRenderObject();

    if (imagePaths.isNotEmpty) {
      await Share.shareFiles(imagePaths,
          text: text,
          subject: subject,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(text,
          subject: subject,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  _onShareWithEmptyOrigin(BuildContext context) async {
    await Share.share("text");
  }
}
