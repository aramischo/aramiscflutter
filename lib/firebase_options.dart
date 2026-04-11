import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRyJGPyNb8ls1NSvdB5YCatxdXPXHvAiY',
    appId: '1:128471507533:android:58297c726be8442ea5b204',
    messagingSenderId: '128471507533',
    projectId: 'aramiscsys',
    storageBucket: 'aramiscsys.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDGkkVxZVvH_sqHUZQTOgVQxwVLhUp4pto',
    appId: '1:128471507533:ios:4f880218f0cd8a6ba5b204',
    messagingSenderId: '128471507533',
    projectId: 'aramiscsys',
    storageBucket: 'aramiscsys.firebasestorage.app',
    iosBundleId: 'com.edu.aramiscsys.aramisc',
  );
}
