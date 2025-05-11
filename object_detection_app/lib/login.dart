// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'user_dashboard.dart';
// import 'guardian_dashboard.dart';
// import 'user_dashboard.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   String loginType = "user"; // or 'guardian'
//   bool _isLoading = false;

//   void login() async {
//     final email = emailController.text.trim();
//     final pass = passwordController.text.trim();

//     if (email.isEmpty || pass.isEmpty) {
//       showError("Please enter email and password");
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Sign in with Firebase Authentication
//       UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: pass);

//       final uid = userCredential.user!.uid;
//       final token = await FirebaseMessaging.instance.getToken();

//       dynamic userData;

//       if (loginType == "user") {
//         // Get user data from Firestore
//         final snapshot =
//             await FirebaseFirestore.instance.collection("users").doc(uid).get();
//         if (!snapshot.exists) throw Exception("User not found!");
//         userData = snapshot.data();

//         // Save FCM token
//         await FirebaseFirestore.instance.collection("users").doc(uid).update({
//           'fcmToken': token,
//         });
//       } else {
//         // Get guardian data from Firestore
//         final snapshot = await FirebaseFirestore.instance
//             .collection("guardians")
//             .doc(uid)
//             .get();
//         if (!snapshot.exists) throw Exception("Guardian not found!");
//         userData = snapshot.data();

//         // Save FCM token
//         await FirebaseFirestore.instance
//             .collection("guardians")
//             .doc(uid)
//             .update({
//           'fcmToken': token,
//         });
//       }

//       // Navigate to respective dashboard
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => loginType == "user"
//               ? ObjectDetectScreen(userData: userData)
//               : GuardianDashboard(guardianData: userData),
//         ),
//       );
//     } on FirebaseAuthException catch (e) {
//       showError(e.message ?? "Login failed. Please try again.");
//     } catch (e) {
//       showError(e.toString());
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // void login() async {
//   //   final email = emailController.text.trim();
//   //   final pass = passwordController.text.trim();

//   //   if (email.isEmpty || pass.isEmpty) {
//   //     showError("Please enter email and password");
//   //     return;
//   //   }

//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   try {
//   //     // Sign in with Firebase Authentication
//   //     UserCredential userCredential = await FirebaseAuth.instance
//   //         .signInWithEmailAndPassword(email: email, password: pass);

//   //     // Get user data from Firestore after login
//   //     var userData = await _fetchUserData(userCredential.user!.uid);

//   //     // Navigate to respective dashboard based on login type
//   //     Navigator.pushReplacement(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (_) => loginType == "user"
//   //             ? ObjectDetectScreen(userData: userData)
//   //             : GuardianDashboard(guardianData: userData),
//   //       ),
//   //     );
//   //   } on FirebaseAuthException catch (e) {
//   //     showError(e.message ?? "Login failed. Please try again.");
//   //   } finally {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   Future<void> saveGuardianToken(String uid) async {
//     final token = await FirebaseMessaging.instance.getToken();
//     if (token != null) {
//       await FirebaseFirestore.instance.collection('guardians').doc(uid).update({
//         'fcmToken': token,
//       });
//     }
//   }

//   Future<Map<String, dynamic>> _fetchUserData(String uid) async {
//     // Fetch user data from Firestore (modify the collection as needed)
//     // Example for fetching user data from Firestore collection 'users' or 'guardians'
//     var snapshot = await FirebaseFirestore.instance
//         .collection(loginType == 'user' ? 'users' : 'guardians')
//         .doc(uid)
//         .get();

//     if (snapshot.exists) {
//       return snapshot.data() as Map<String, dynamic>;
//     } else {
//       throw Exception("No user data found");
//     }
//   }

//   void showError(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Login - DrishtiMate",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // LOGO
//             Center(
//               child: Image.asset(
//                 'assets/images/DrishtiMate.png', // Make sure this path matches your assets folder
//                 height: 200,
//               ),
//             ),
//             SizedBox(height: 20),

//             // LOGIN TYPE TOGGLE BUTTONS
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => setState(() => loginType = "user"),
//                   child: Text(
//                     "Login as User",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         loginType == "user" ? Colors.blue : Colors.grey[600],
//                     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: () => setState(() => loginType = "guardian"),
//                   child: Text(
//                     "Login as Guardian",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: loginType == "guardian"
//                         ? Colors.green
//                         : Colors.grey[600],
//                     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30),

//             // EMAIL
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(
//                 labelText: "Email",
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             SizedBox(height: 20),

//             // PASSWORD
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: "Password",
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//             SizedBox(height: 20),

//             // LOGIN BUTTON
//             _isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : ElevatedButton(
//                     onPressed: login,
//                     child: Text(
//                       "Login",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       padding: EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//             SizedBox(height: 20),

//             // SIGN UP NAVIGATION
//             TextButton(
//               onPressed: () {
//                 loginType == "user"
//                     ? Navigator.pushNamed(context, "/signup")
//                     : Navigator.pushNamed(context, "/gaurdiansignup");
//               },
//               child: Text("Don't have an account? Sign Up"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'user_dashboard.dart';
import 'guardian_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String loginType = "user";
  bool _isLoading = false;

  void login() async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      showError("Please enter email and password");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      final uid = userCredential.user!.uid;
      final token = await FirebaseMessaging.instance.getToken();

      final collection = loginType == 'user' ? 'users' : 'guardians';
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(uid)
          .get();

      if (!snapshot.exists) throw Exception("User not found!");
      final userData = snapshot.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection(collection)
          .doc(uid)
          .update({'fcmToken': token});

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => loginType == "user"
              ? ObjectDetectScreen(userData: userData)
              : GuardianDashboard(guardianData: userData),
        ),
      );
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showError(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD8EDE4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              height: 450,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/DrishtiMate.png'), // replace with torn image background if available
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.bottomCenter,
              // child: Padding(
              //   padding: const EdgeInsets.only(bottom: 20.0),
              //   child: Text(
              //     // "DrishtiMate.",
              //     style: TextStyle(
              //       fontSize: 28,
              //       fontWeight: FontWeight.w700,
              //       color: Color(0xFF4E7D6A),
              //     ),
              //   ),
            ),

            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                setState(() {
                  loginType = loginType == 'user' ? 'guardian' : 'user';
                });
              },
              child: Text(
                loginType == 'user' ? "Login User" : "Login Guardian",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF294B3A),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tap above link to change login ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  // Name Field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Name",
                      filled: true,
                      fillColor: Color(0xFFB4D3C3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Color(0xFFB4D3C3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E5D49),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      loginType == "user"
                          ? Navigator.pushNamed(context, "/signup")
                          : Navigator.pushNamed(context, "/gaurdiansignup");
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: Colors.black87,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
