import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ✅ Cấu hình Web (dùng khi chạy Flutter Web)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDFvWVJA-RHGKBeLlR8--PJpT_4NCYk4OA",
    authDomain: "matcha-95358.firebaseapp.com",
    projectId: "matcha-95358",
    storageBucket: "matcha-95358.firebasestorage.app",
    messagingSenderId: "394788901118",
    appId: "1:394788901118:web:beaf125b5153295b5055af",
    measurementId: "G-PJEBWBW8V1",
  );

  // ✅ Cấu hình Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDFvWVJA-RHGKBeLlR8--PJpT_4NCYk4OA",
    appId: "1:394788901118:android:beaf125b5153295b5055af",
    messagingSenderId: "394788901118",
    projectId: "matcha-95358",
    storageBucket: "matcha-95358.firebasestorage.app",
  );

  // ✅ Nếu sau này bạn add iOS, macOS, Windows, Linux thì điền vào đây
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDFvWVJA-RHGKBeLlR8--PJpT_4NCYk4OA",
    appId: "1:394788901118:ios:beaf125b5153295b5055af",
    messagingSenderId: "394788901118",
    projectId: "matcha-95358",
    storageBucket: "matcha-95358.firebasestorage.app",
    iosBundleId: "com.example.matcha", // sửa cho đúng bundleId iOS của bạn
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = android;
  static const FirebaseOptions linux = android;
}
