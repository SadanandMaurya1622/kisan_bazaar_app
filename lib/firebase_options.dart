import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXqCjjI6tSW4SgzxZpUInuHLnISgTFFYU',
    appId: '1:429240384407:android:2a6166306c7bf8397be2d2',
    messagingSenderId: '429240384407',
    projectId: 'kisanbazaar-53646',
    storageBucket: 'kisanbazaar-53646.firebasestorage.app',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase options are not configured for web platform.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase options are not configured for this platform.',
        );
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }
}
