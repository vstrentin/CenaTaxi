// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyAdYt7KSvGrIriW3axhlfeeB_daKo0IDNY',
    appId: '1:390516140677:web:f986931b05eafb7ef857ec',
    messagingSenderId: '390516140677',
    projectId: 'cena-taxi',
    authDomain: 'cena-taxi.firebaseapp.com',
    storageBucket: 'cena-taxi.firebasestorage.app',
    measurementId: 'G-5GRQSN11LK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdnLCHCvbCv2dQAxqhDAg2JW47m5Hr1xA',
    appId: '1:390516140677:android:ad7656ea68a6515ff857ec',
    messagingSenderId: '390516140677',
    projectId: 'cena-taxi',
    storageBucket: 'cena-taxi.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQsMNP9yZgRLOuzcBrWTADyp3R5SHv_Lg',
    appId: '1:390516140677:ios:9b91a4f36cdc5be0f857ec',
    messagingSenderId: '390516140677',
    projectId: 'cena-taxi',
    storageBucket: 'cena-taxi.firebasestorage.app',
    iosBundleId: 'com.example.cenaTaxi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQsMNP9yZgRLOuzcBrWTADyp3R5SHv_Lg',
    appId: '1:390516140677:ios:9b91a4f36cdc5be0f857ec',
    messagingSenderId: '390516140677',
    projectId: 'cena-taxi',
    storageBucket: 'cena-taxi.firebasestorage.app',
    iosBundleId: 'com.example.cenaTaxi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAdYt7KSvGrIriW3axhlfeeB_daKo0IDNY',
    appId: '1:390516140677:web:fe253a46262d6963f857ec',
    messagingSenderId: '390516140677',
    projectId: 'cena-taxi',
    authDomain: 'cena-taxi.firebaseapp.com',
    storageBucket: 'cena-taxi.firebasestorage.app',
    measurementId: 'G-1JN01D327N',
  );
}
