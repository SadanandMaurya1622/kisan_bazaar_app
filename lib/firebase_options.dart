import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpEpBE6y98NyCWB_aeSHbfIsCQZKSkgtQ',
    appId: '1:844732360071:android:6cc1dd85972ba600a29f22',
    messagingSenderId: '844732360071',
    projectId: 'shopkeep-82465',
    storageBucket: 'shopkeep-82465.appspot.com',
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
