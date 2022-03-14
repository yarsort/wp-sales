import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
        appId: '1:250262606142:android:48194bf52d36e648635c6f',
        apiKey: 'AIzaSyA10xMKwCMGwZ0XybO6NKMnAJW2wqRqi7M',
        projectId: 'wp-sales-729cf',
        messagingSenderId: '250262606142',
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        appId: '1:250262606142:android:48194bf52d36e648635c6f',
        apiKey: 'AIzaSyA10xMKwCMGwZ0XybO6NKMnAJW2wqRqi7M',
        projectId: 'wp-sales-729cf',
        messagingSenderId: '250262606142',
        iosBundleId: 'ua.com.yarsoft.wp_sales',
      );
    } else {
      // Android
      return const FirebaseOptions(
        appId: '1:250262606142:android:48194bf52d36e648635c6f',
        apiKey: 'AIzaSyA10xMKwCMGwZ0XybO6NKMnAJW2wqRqi7M',
        projectId: 'wp-sales-729cf',
        messagingSenderId: '250262606142',
      );
    }
  }
}