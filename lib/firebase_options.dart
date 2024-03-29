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
    apiKey: 'AIzaSyAyiCpK13bFgNEPvwged92TabKOGNacI18',
    appId: '1:478560585618:web:3690c97b64f056ddc1634b',
    messagingSenderId: '478560585618',
    projectId: 'pt-art-d22b7',
    authDomain: 'pt-art-d22b7.firebaseapp.com',
    storageBucket: 'pt-art-d22b7.appspot.com',
    measurementId: 'G-PL9WV425CJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlt7qvCdk7D1oPlrt1T9I7bsh09rkU-xw',
    appId: '1:478560585618:android:f1a77bb5583291b2c1634b',
    messagingSenderId: '478560585618',
    projectId: 'pt-art-d22b7',
    storageBucket: 'pt-art-d22b7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1_SGhsNjTGsNKwnktZLVf6rS8qeWZSvY',
    appId: '1:478560585618:ios:0917dac27d62f08cc1634b',
    messagingSenderId: '478560585618',
    projectId: 'pt-art-d22b7',
    storageBucket: 'pt-art-d22b7.appspot.com',
    iosClientId: '478560585618-coak7n9npbs5p4qih9im4025pg4l81br.apps.googleusercontent.com',
    iosBundleId: 'com.example.art',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD1_SGhsNjTGsNKwnktZLVf6rS8qeWZSvY',
    appId: '1:478560585618:ios:0917dac27d62f08cc1634b',
    messagingSenderId: '478560585618',
    projectId: 'pt-art-d22b7',
    storageBucket: 'pt-art-d22b7.appspot.com',
    iosClientId: '478560585618-coak7n9npbs5p4qih9im4025pg4l81br.apps.googleusercontent.com',
    iosBundleId: 'com.example.art',
  );
}
