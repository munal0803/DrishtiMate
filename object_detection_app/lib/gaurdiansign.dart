import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'guardian_dashboard.dart';

class GuardianSignUpPage extends StatefulWidget {
  @override
  _GuardianSignUpPageState createState() => _GuardianSignUpPageState();
}

class _GuardianSignUpPageState extends State<GuardianSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final userKeyController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  void signUpGuardian() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final uid = credential.user!.uid;

        final guardianData = {
          'name': nameController.text.trim(),
          'guardian phone': phoneController.text.trim(),
          'user key': userKeyController.text.trim(),
          'guardian uid': uid,
        };

        await _firestore.collection('guardians').doc(uid).set(guardianData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GuardianDashboard(guardianData: guardianData),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    userKeyController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $hintText' : null,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.green[100],
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
      backgroundColor: Colors.green[300],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top white area with logo
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "DrishtiMate.",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            Text(
              "Guardian Sign Up",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildStyledTextField(
                      controller: emailController,
                      hintText: "Email",
                      type: TextInputType.emailAddress,
                    ),
                    buildStyledTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscure: true,
                    ),
                    buildStyledTextField(
                      controller: nameController,
                      hintText: "Guardian Name",
                    ),
                    buildStyledTextField(
                      controller: phoneController,
                      hintText: "Phone Number",
                      type: TextInputType.phone,
                    ),
                    buildStyledTextField(
                      controller: userKeyController,
                      hintText: "User Key",
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: signUpGuardian,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 14),
                            ),
                            child: Text("Sign Up",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                    SizedBox(height: 30),
                    Text(
                      "www.drishtimate.tech",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
