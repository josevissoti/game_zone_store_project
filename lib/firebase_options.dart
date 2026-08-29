import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCFxnK7TZMBWcpZ8Tz7eomJ_qJIWb0ip8c',
    authDomain: 'gamezone-e35a8.firebaseapp.com',
    databaseURL: 'https://gamezone-e35a8-default-rtdb.firebaseio.com',
    projectId: 'gamezone-e35a8',
    storageBucket: 'gamezone-e35a8.firebasestorage.app',
    messagingSenderId: '288846042935',
    appId: '1:288846042935:web:36f0b1c95bc1587b92ecb2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFxnK7TZMBWcpZ8Tz7eomJ_qJIWb0ip8c',
    authDomain: 'gamezone-e35a8.firebaseapp.com',
    databaseURL: 'https://gamezone-e35a8-default-rtdb.firebaseio.com',
    projectId: 'gamezone-e35a8',
    storageBucket: 'gamezone-e35a8.firebasestorage.app',
    messagingSenderId: '288846042935',
    appId: '1:288846042935:android:36f0b1c95bc1587b92ecb2',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFxnK7TZMBWcpZ8Tz7eomJ_qJIWb0ip8c',
    authDomain: 'gamezone-e35a8.firebaseapp.com',
    databaseURL: 'https://gamezone-e35a8-default-rtdb.firebaseio.com',
    projectId: 'gamezone-e35a8',
    storageBucket: 'gamezone-e35a8.firebasestorage.app',
    messagingSenderId: '288846042935',
    appId: '1:288846042935:ios:36f0b1c95bc1587b92ecb2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCFxnK7TZMBWcpZ8Tz7eomJ_qJIWb0ip8c',
    authDomain: 'gamezone-e35a8.firebaseapp.com',
    databaseURL: 'https://gamezone-e35a8-default-rtdb.firebaseio.com',
    projectId: 'gamezone-e35a8',
    storageBucket: 'gamezone-e35a8.firebasestorage.app',
    messagingSenderId: '288846042935',
    appId: '1:288846042935:macos:36f0b1c95bc1587b92ecb2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCFxnK7TZMBWcpZ8Tz7eomJ_qJIWb0ip8c',
    authDomain: 'gamezone-e35a8.firebaseapp.com',
    databaseURL: 'https://gamezone-e35a8-default-rtdb.firebaseio.com',
    projectId: 'gamezone-e35a8',
    storageBucket: 'gamezone-e35a8.firebasestorage.app',
    messagingSenderId: '288846042935',
    appId: '1:288846042935:windows:36f0b1c95bc1587b92ecb2',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCFxnK7TZMBWcpZ8Tz7eomJ_qJIWb0ip8c',
    authDomain: 'gamezone-e35a8.firebaseapp.com',
    databaseURL: 'https://gamezone-e35a8-default-rtdb.firebaseio.com',
    projectId: 'gamezone-e35a8',
    storageBucket: 'gamezone-e35a8.firebasestorage.app',
    messagingSenderId: '288846042935',
    appId: '1:288846042935:linux:36f0b1c95bc1587b92ecb2',
  );
}