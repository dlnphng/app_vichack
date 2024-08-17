import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({Key? key}) : super(key: key);

  @override
  _UserSettingPageState createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  String? _userName;
  String? _avatarUrl;
  String? _university;
  String? _email;
  final TextEditingController _universityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          _userName = data?['name'] ?? 'User Name';
          _avatarUrl = data?['avatarUrl'];
          _university = data?['university'] ?? 'Not Provided';
          _email = user.email;
          _universityController.text = _university ?? '';
        });
      } else {
        print("User document does not exist.");
      }
    } else {
      print("No authenticated user found.");
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _updateUniversity() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'university': _universityController.text,
      });
      setState(() {
        _university = _universityController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("University updated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        backgroundColor: const Color.fromARGB(255, 255, 193, 86),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                    backgroundColor: const Color.fromARGB(255, 252, 186, 85),
                    child: _avatarUrl == null
                        ? const Icon(
                            Icons.account_circle,
                            size: 120,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userName ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _email ?? 'Email Not Available',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _universityController,
                    decoration: const InputDecoration(
                      labelText: 'University',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUniversity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 193, 86),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Update University',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 193, 86),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
