// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocery_app_admin/add_food.dart';
import 'package:grocery_app_admin/admin_login.dart';
import 'package:grocery_app_admin/my_products.dart';
import 'package:grocery_app_admin/notifications.dart';
import 'package:grocery_app_admin/services/services.dart';
import 'package:grocery_app_admin/widgets/text_style.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  String? storeName;
  String imgUrl = '';

  @override
  void initState() {
    super.initState();
    fetchStoreName();
  }

  Future<void> fetchStoreName() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (kDebugMode) {
        print("Current user ID: $userId");
      }

      if (userId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection("Admin")
            .doc(userId)
            .get();

        if (snapshot.exists) {
          setState(() {
            storeName = snapshot.get("id");
            if (kDebugMode) {
              print("Store name set to: $storeName");
            } // Debugging print
          });
        } else {
          if (kDebugMode) {
            print("No matching document found for the user ID.");
          }
        }
      } else {
        if (kDebugMode) {
          print("No user is currently signed in.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching store name: $e");
      }
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLogin()),
    );
  }

  final controller = Get.put(ImagePickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home Admin"),
      ),
      drawer: SafeArea(
        child: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Obx(() {
                      return InkWell(
                        onTap: () async {
                          controller.pickImage();
                          imgUrl = await controller.uploadImageToFirebase();
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          child: ClipOval(
                            child: controller.image.value == null ||
                                    controller.image.value!.path == ''
                                ? const Icon(Icons.camera)
                                : AspectRatio(
                                    aspectRatio: 1.0,
                                    child: Image.file(
                                      controller.image.value!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),
                    Text(
                      storeName ?? "Loading...",
                      style: AppWidgets.semiBoldTextFieldStyle(),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Color(0XFF8a4af3)),
                title: const Text('Add Product',
                    style: TextStyle(color: Color(0XFF8a4af3))),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AddFood()));
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.chat_outlined, color: Color(0XFF8a4af3)),
                title: const Text('Chat Screen',
                    style: TextStyle(color: Color(0XFF8a4af3))),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreens()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory, color: Color(0XFF8a4af3)),
                title: const Text('My Products',
                    style: TextStyle(color: Color(0XFF8a4af3))),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyProducts()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0XFF8a4af3)),
                title: const Text('Logout',
                    style: TextStyle(color: Color(0XFF8a4af3))),
                onTap: signOut,
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your Orders",
              style: AppWidgets.boldTextFieldStyle(),
            )
          ],
        ),
      ),
    );
  }
}
