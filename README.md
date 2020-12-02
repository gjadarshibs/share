# share

Simple wrapper classes for sharing content via the platform share UI, using the ACTION_SEND intent on Android and UIActivityViewController.

## How to use

Import the package in your dart file

```dart
import 'package:share/share.dart';
```

## How to use
For sharing a file, the path name of the file along with other parameters need to be passed

```dart
Share.shareFiles(['$directory/iFlyTicket.png'],
          subject: 'Sharing iFly e-Ticket',
          text: 'This is your iFly e-Ticket',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
```

share method

| Attribute            | Type                  
| ----------------     | -------------------
| text                 | String(Mandatory)  
| subject              | String           
| sharePositionOrigin  | Rect  

shareFiles method

| Attribute            | Type                  
| ----------------     | -------------------
| paths                | List<String>(Mandatory)  
| mimeTypes            | List<String>  
| text                 | String  
| subject              | String           
| sharePositionOrigin  | Rect  


For other info on the plugin used, please refer:
This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

