import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

abstract class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDikHoaUqaIQ_MKEfQZRW1MLNwCRy2KazM',
    appId: '1:451513472757:android:0a862417fa58860903d7bc',
    messagingSenderId: '451513472757',
    projectId: 'kelime-hazinem-ar-tr',
    storageBucket: 'kelime-hazinem-ar-tr.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByCwXJXSiL7Da7x2RX77M3JfNFjexoV7I',
    appId: '1:451513472757:ios:05d908aad8d9e5d303d7bc',
    messagingSenderId: '451513472757',
    projectId: 'kelime-hazinem-ar-tr',
    storageBucket: 'kelime-hazinem-ar-tr.appspot.com',
    iosClientId: '451513472757-k71kgpuiifo4l07tmpgtulsnoig0hbkg.apps.googleusercontent.com',
    iosBundleId: 'com.kelimehazinem.arTr',
  );
}
