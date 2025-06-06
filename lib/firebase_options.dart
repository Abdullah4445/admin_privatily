// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
//Saim

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAiLyxkE5PhIJ5cG9WJHNQLUPupZtPm3eA',
    appId: '1:935975375761:web:969288cc6d4aec04b74030',
    messagingSenderId: '935975375761',
    projectId: 'billtech-6f3b1',
    authDomain: 'billtech-6f3b1.firebaseapp.com',
    storageBucket: 'billtech-6f3b1.appspot.com',
    measurementId: 'G-CKJ0CF8412',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3HGQ8AtMYDkEEsHbBmC2MNF9eg-mwA2c',
    appId: '1:935975375761:android:ecfadcdbbf947d31b74030',
    messagingSenderId: '935975375761',
    projectId: 'billtech-6f3b1',
    storageBucket: 'billtech-6f3b1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQyrLDO1opmeYvKLDpIZJI9OPwZybMMV0',
    appId: '1:935975375761:ios:3d11c33982cda49fb74030',
    messagingSenderId: '935975375761',
    projectId: 'billtech-6f3b1',
    storageBucket: 'billtech-6f3b1.appspot.com',
    iosClientId: '935975375761-9ikfl8v8cs0sr6i8n6n5rpqaan51jp3h.apps.googleusercontent.com',
    iosBundleId: 'com.aiHub.adminPrivatily',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQyrLDO1opmeYvKLDpIZJI9OPwZybMMV0',
    appId: '1:935975375761:ios:3d11c33982cda49fb74030',
    messagingSenderId: '935975375761',
    projectId: 'billtech-6f3b1',
    storageBucket: 'billtech-6f3b1.appspot.com',
    iosClientId: '935975375761-9ikfl8v8cs0sr6i8n6n5rpqaan51jp3h.apps.googleusercontent.com',
    iosBundleId: 'com.aiHub.adminPrivatily',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCAOmgMUPlUTh4KE7y0Li5ZKH_0S038OBs',
    appId: '1:935975375761:web:615968393e85598fb74030',
    messagingSenderId: '935975375761',
    projectId: 'billtech-6f3b1',
    authDomain: 'billtech-6f3b1.firebaseapp.com',
    storageBucket: 'billtech-6f3b1.appspot.com',
    measurementId: 'G-1Q147Q9MVC',
  );

}