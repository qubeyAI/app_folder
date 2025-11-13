import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'firebase_core_platform_interface/firebase_core_platform_interface.dart';


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyDDTkDTLgwOZsxGGhKVuIt35q4kAXnbjI4",
      appId: "1:263184158315:android:da9087f939bc5120732b2e",
      messagingSenderId: "263184158315",
      projectId: "fir-flutter-auth-b89e6",
    );
  }
}