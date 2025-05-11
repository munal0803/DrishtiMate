import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'guardian_dashboard.dart';
import 'user_dashboard.dart';
import 'login.dart';

class SessionWrapper extends StatelessWidget {
  const SessionWrapper({super.key});

  Future<Widget> _checkLoginAndRedirect() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // First check in 'users'
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userSnap.exists) {
        return ObjectDetectScreen(
            userData: userSnap.data() as Map<String, dynamic>);
      }

      // Then check in 'guardians'
      DocumentSnapshot guardianSnap = await FirebaseFirestore.instance
          .collection('guardians')
          .doc(user.uid)
          .get();
      if (guardianSnap.exists) {
        return GuardianDashboard(
            guardianData: guardianSnap.data() as Map<String, dynamic>);
      }

      // If no data found
      await FirebaseAuth.instance.signOut();
    }

    return const LoginPage(); // Not logged in
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkLoginAndRedirect(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text("Something went wrong")));
        } else {
          return snapshot.data!;
        }
      },
    );
  }
}
