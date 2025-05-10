import 'package:admin_privatily/login_screen/view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth
import 'package:admin_privatily/firebase_utils.dart';  // Import firebase_utils.dart

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Get the current user after Firebase initialization
  final user = FirebaseAuth.instance.currentUser;

  // Call setUserOnline if the user is already logged in
  if (user != null) {
    await setUserOnline();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignIn_page(),
    );
  }
}