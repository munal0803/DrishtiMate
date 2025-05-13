import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class GuardianDashboard extends StatefulWidget {
  final Map<String, dynamic> guardianData;

  const GuardianDashboard({required this.guardianData});

  @override
  State<GuardianDashboard> createState() => _GuardianDashboardState();
}

class _GuardianDashboardState extends State<GuardianDashboard> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  static const double padding = 20.0;
  static const double spacing = 16.0;
  static const double avatarSize = 48.0;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('user key', isEqualTo: widget.guardianData['user key'])
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          userData = query.docs.first.data();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found for the provided user key.')),
        );
      }
    } catch (e) {
      print("Error fetching user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> launchPhone(String number) async {
    final uri = Uri.parse("tel:$number");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cannot open dialer.")));
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: Colors.green[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.black),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Guardian Dashboard'),
        ),
        drawer: buildDrawer(),
        body: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.green))
            : userData == null
                ? Center(child: Text("User data not found."))
                : buildContent(),
      ),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[200]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("👨‍👩‍👧 Guardian Info",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: spacing),
                drawerText("Name: ${widget.guardianData['name']}"),
                drawerText("Phone: ${widget.guardianData['guardian phone']}"),
                drawerText("User Key: ${widget.guardianData['user key']}"),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout'),
            onTap: logout,
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildUserCard(),
          SizedBox(height: spacing),
          buildSearchHistory(),
        ],
      ),
    );
  }

  Widget buildUserCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarSize,
              backgroundColor: Colors.green[300],
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoText("👤 ${userData!['name']}", isBold: true),
                  SizedBox(height: 8),
                  infoText("Age: ${userData!['user age']}"),
                  infoText("Guardian: ${userData!['guardian name']}"),
                  SizedBox(height: 12),
                  phoneRow("Guardian Phone", userData!['guardian phone']),
                  phoneRow("Doctor Number", userData!['doctor number']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchHistory() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.green[100],
        backgroundColor: Colors.green[50],
        title: Text("📚 Search History",
            style: TextStyle(fontWeight: FontWeight.bold)),
        children: userData!['searches'] != null
            ? List.generate(userData!['searches'].length, (index) {
                final search = userData!['searches'][index];
                return ListTile(
                  title: Text("🔍 ${search['text']}"),
                  subtitle: Text("🕒 ${search['timestamp']}"),
                );
              })
            : [ListTile(title: Text("No searches found"))],
      ),
    );
  }

  Widget phoneRow(String label, String number) {
    return Row(
      children: [
        Expanded(
          child: Text("$label: $number",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        IconButton(
          icon: Icon(Icons.call, color: Colors.green[700]),
          onPressed: () => launchPhone(number),
        ),
      ],
    );
  }

  Widget infoText(String text, {bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget drawerText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 14)),
    );
  }
}
