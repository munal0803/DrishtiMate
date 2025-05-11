import 'package:flutter/material.dart';
import 'package:object_detection_app/gaurdiansign.dart';
import 'package:object_detection_app/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:object_detection_app/session_wrapper.dart';
import 'package:object_detection_app/user_dashboard.dart';
import 'package:object_detection_app/usersign.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  // initialize cameras
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SessionWrapper(),
    routes: {
      "/signup": (context) => UserSignUpPage(),
      "/gaurdiansignup": (context) => GuardianSignUpPage(),
      "/login": (context) => LoginPage(),
    },
  ));
}
