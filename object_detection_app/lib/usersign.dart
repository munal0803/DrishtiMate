// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'user_dashboard.dart'; // Replace with actual path if needed

// class UserSignUpPage extends StatefulWidget {
//   @override
//   _UserSignUpPageState createState() => _UserSignUpPageState();
// }

// class _UserSignUpPageState extends State<UserSignUpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _guardianNameController = TextEditingController();
//   final _guardianPhoneController = TextEditingController();
//   final _userAgeController = TextEditingController();
//   final _userKeyController = TextEditingController(); // <--- User provides this
//   final _doctorNumberController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> signUpUser() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       UserCredential userCredential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );

//       String uid = userCredential.user!.uid;
//       String userKey = _userKeyController.text.trim();

//       await _firestore.collection('users').add({
//         'name': _nameController.text.trim(),
//         'guardian name': _guardianNameController.text.trim(),
//         'guardian phone': _guardianPhoneController.text.trim(),
//         'user age': _userAgeController.text.trim(),
//         'user key': userKey,
//         'doctor number': _doctorNumberController.text.trim(),
//         'searches': [],
//       });

//       Fluttertoast.showToast(msg: "User account created successfully!");

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ObjectDetectScreen(userData: {
//             'name': _nameController.text.trim(),
//             'user key': userKey,
//           }),
//         ),
//       );
//     } on FirebaseAuthException catch (e) {
//       Fluttertoast.showToast(msg: e.message ?? "Signup failed.");
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Unexpected error occurred.");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Widget buildTextField(
//     TextEditingController controller,
//     String label, {
//     TextInputType keyboardType = TextInputType.text,
//     bool isPassword = false,
//     String? Function(String?)? validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextFormField(
//         controller: controller,
//         obscureText: isPassword,
//         keyboardType: keyboardType,
//         validator: validator ??
//             (value) => value == null || value.isEmpty ? 'Enter $label' : null,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(fontSize: 16),
//           filled: true,
//           fillColor: Colors.grey[100],
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.blue, width: 1.5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text("User Sign Up", style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: Colors.blue.shade600,
//         elevation: 0,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Icon(Icons.person_add_alt_1,
//                     size: 100, color: Colors.blueAccent),
//                 SizedBox(height: 10),
//                 Text(
//                   "Create Your Account",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 20),
//                 buildTextField(_nameController, 'Name'),
//                 buildTextField(_guardianNameController, 'Guardian Name'),
//                 buildTextField(
//                   _guardianPhoneController,
//                   'Guardian Phone',
//                   keyboardType: TextInputType.phone,
//                   validator: (value) => value == null || value.length != 10
//                       ? 'Enter 10-digit phone number'
//                       : null,
//                 ),
//                 buildTextField(
//                   _userAgeController,
//                   'User Age ( use for finding guardian )',
//                   keyboardType: TextInputType.number,
//                 ),
//                 buildTextField(
//                   _doctorNumberController,
//                   'Doctor Number',
//                   keyboardType: TextInputType.phone,
//                 ),
//                 buildTextField(
//                   _userKeyController,
//                   'User Key', // <--- Let user enter their key
//                   validator: (value) => value == null || value.trim().isEmpty
//                       ? 'User Key is required'
//                       : null,
//                 ),
//                 buildTextField(
//                   _emailController,
//                   'Email',
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 buildTextField(
//                   _passwordController,
//                   'Password',
//                   isPassword: true,
//                 ),
//                 SizedBox(height: 24),
//                 _isLoading
//                     ? CircularProgressIndicator()
//                     : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 40, vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           backgroundColor: Colors.blueAccent,
//                         ),
//                         onPressed: signUpUser,
//                         child: Text(
//                           'Sign Up',
//                           style: TextStyle(fontSize: 18, color: Colors.white),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'user_dashboard.dart'; // Replace with your actual path

class UserSignUpPage extends StatefulWidget {
  @override
  _UserSignUpPageState createState() => _UserSignUpPageState();
}

class _UserSignUpPageState extends State<UserSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _userAgeController = TextEditingController();
  final _userKeyController = TextEditingController();
  final _doctorNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUpUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String userKey = _userKeyController.text.trim();

      await _firestore.collection('users').add({
        'name': _nameController.text.trim(),
        'guardian name': _guardianNameController.text.trim(),
        'guardian phone': _guardianPhoneController.text.trim(),
        'user age': _userAgeController.text.trim(),
        'user key': userKey,
        'doctor number': _doctorNumberController.text.trim(),
        'searches': [],
      });

      Fluttertoast.showToast(msg: "User account created successfully!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ObjectDetectScreen(userData: {
            'name': _nameController.text.trim(),
            'user key': userKey,
          }),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Signup failed. ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget buildGreenField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text,
      bool isPassword = false,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator ??
            (value) => value == null || value.isEmpty ? 'Enter $hint' : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Color(0xFFB8E0C6), // light green background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background decorative top wave or gradient
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB8E0C6), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text(
                      "DrishtiMate.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Create New Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color(0xFF294B3A),
                      ),
                    ),
                    SizedBox(height: 20),
                    buildGreenField(_nameController, 'Name'),
                    buildGreenField(_guardianNameController, 'Guardian Name'),
                    buildGreenField(
                      _guardianPhoneController,
                      'Guardian Phone',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.length != 10
                          ? 'Enter 10-digit phone number'
                          : null,
                    ),
                    buildGreenField(
                      _userAgeController,
                      'User Age (use for finding guardian)',
                      keyboardType: TextInputType.number,
                    ),
                    buildGreenField(
                      _doctorNumberController,
                      'Doctor Number',
                      keyboardType: TextInputType.phone,
                    ),
                    buildGreenField(
                      _userKeyController,
                      'User Key',
                      validator: (value) => value == null || value.isEmpty
                          ? 'User Key is required'
                          : null,
                    ),
                    buildGreenField(
                      _emailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    buildGreenField(
                      _passwordController,
                      'Password',
                      isPassword: true,
                    ),
                    SizedBox(height: 24),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: signUpUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF294B3A),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Sign Up",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                    SizedBox(height: 30),
                    Text(
                      "www.drishtiMate.tech",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
