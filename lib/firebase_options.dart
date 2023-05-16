// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA_yXIpo-xsscCdMjEI-9r6Jg-8ihI5riY',
    appId: '1:431625325710:web:8f89c2a602164bc0368ddf',
    messagingSenderId: '431625325710',
    projectId: 'time-mgmt-app-flutter-ff81e',
    authDomain: 'time-mgmt-app-flutter-ff81e.firebaseapp.com',
    databaseURL: 'https://time-mgmt-app-flutter-ff81e-default-rtdb.firebaseio.com',
    storageBucket: 'time-mgmt-app-flutter-ff81e.appspot.com',
    measurementId: 'G-DDDN0327CP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACncsPWJudJn_pUkgO6-AETfQcKx8e8dU',
    appId: '1:431625325710:android:003072c89d455a3e368ddf',
    messagingSenderId: '431625325710',
    projectId: 'time-mgmt-app-flutter-ff81e',
    databaseURL: 'https://time-mgmt-app-flutter-ff81e-default-rtdb.firebaseio.com',
    storageBucket: 'time-mgmt-app-flutter-ff81e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDwog5wtKzIVuShl2SVdY2ywBZEdvgG40',
    appId: '1:431625325710:ios:d51584eaf96ca1b7368ddf',
    messagingSenderId: '431625325710',
    projectId: 'time-mgmt-app-flutter-ff81e',
    databaseURL: 'https://time-mgmt-app-flutter-ff81e-default-rtdb.firebaseio.com',
    storageBucket: 'time-mgmt-app-flutter-ff81e.appspot.com',
    iosClientId: '431625325710-soa4mlucijphlgj4951rcsophfaksh52.apps.googleusercontent.com',
    iosBundleId: 'com.example.timeMgmtApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDDwog5wtKzIVuShl2SVdY2ywBZEdvgG40',
    appId: '1:431625325710:ios:d51584eaf96ca1b7368ddf',
    messagingSenderId: '431625325710',
    projectId: 'time-mgmt-app-flutter-ff81e',
    databaseURL: 'https://time-mgmt-app-flutter-ff81e-default-rtdb.firebaseio.com',
    storageBucket: 'time-mgmt-app-flutter-ff81e.appspot.com',
    iosClientId: '431625325710-soa4mlucijphlgj4951rcsophfaksh52.apps.googleusercontent.com',
    iosBundleId: 'com.example.timeMgmtApp',
  );
}
