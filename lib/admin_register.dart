import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/admin_login.dart';
import 'package:grocery_app_admin/home_admin.dart';
import 'package:grocery_app_admin/responsive/web_responsive.dart';
import 'package:grocery_app_admin/widgets/utils.dart';

class AdminRegister extends StatefulWidget {
  const AdminRegister({super.key});

  @override
  State<AdminRegister> createState() => _AdminRegisterState();
}

class _AdminRegisterState extends State<AdminRegister> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  bool isRegistering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFededeb),
      body: Stack(
        children: [
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
            padding: const EdgeInsets.only(top: 45.0, left: 20.0, right: 20.0),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 53, 51, 51), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                top:
                    Radius.elliptical(MediaQuery.of(context).size.width, 110.0),
              ),
            ),
          ),
          WebResponsive(
            child: Container(
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 60.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Let's start with\nAdmin!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 1.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 30.0),
                              _buildTextField("Email", emailController),
                              const SizedBox(height: 20.0),
                              _buildTextField("Shop Name", usernameController),
                              const SizedBox(height: 20.0),
                              _buildTextField(
                                  "Password", userPasswordController,
                                  isPassword: true),
                              const SizedBox(height: 40.0),
                              GestureDetector(
                                onTap: () {
                                  registerAdmin();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Register",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AdminLogin()));
                                },
                                child: Text("Already have an account? Login"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 160, 160, 147)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hint';
          }
          return null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 160, 160, 147)),
        ),
      ),
    );
  }

  Future<void> registerAdmin() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = userPasswordController.text.trim();

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection("Admin")
          .doc(userCredential.user?.uid)
          .set({
        'email': email,
        'id': username,
      });

      Utils.toastMessage("Admin Registered successfully!");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdmin()),
      );
    } catch (error) {
      Utils.toastMessage("Registration failed: $error");
    }
  }
}
