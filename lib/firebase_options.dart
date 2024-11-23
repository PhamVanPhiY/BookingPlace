import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCDkLGXqSJqqJAGJ1mW7MdnHvXzeAEyQFI',
    appId: '1:817468766043:web:4aadb269982fcfc7f54c7e',
    messagingSenderId: '817468766043',
    projectId: 'bookingplace-31e57',
    authDomain: 'bookingplace-31e57.firebaseapp.com',
    storageBucket: 'bookingplace-31e57.appspot.com',
    measurementId: 'G-8S6PDMLQ12',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMJqUZnBzN753KtVhSPi-nDLwQ9SZYHkM',
    appId: '1:817468766043:android:89c3722bb9f07616f54c7e',
    messagingSenderId: '817468766043',
    projectId: 'bookingplace-31e57',
    storageBucket: 'bookingplace-31e57.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATJ8cSyL4F7hu_j0m_VrdPUZ92LX-WJFw',
    appId: '1:817468766043:ios:45ca673280f645b5f54c7e',
    messagingSenderId: '817468766043',
    projectId: 'bookingplace-31e57',
    storageBucket: 'bookingplace-31e57.appspot.com',
    iosBundleId:
        'com.example.bookingPlace', // Ensure this is correct in your Xcode project
  );
}
