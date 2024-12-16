// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocery_app_admin/add_food.dart';
import 'package:grocery_app_admin/admin_login.dart';
import 'package:grocery_app_admin/my_products.dart';
import 'package:grocery_app_admin/notifications.dart';
import 'package:grocery_app_admin/services/services.dart';
import 'package:grocery_app_admin/widgets/order_list.dart';
import 'package:grocery_app_admin/widgets/text_style.dart';
import 'package:intl/intl.dart';

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
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLogIn()),
    );
  }

  final controller = Get.put(ImagePickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Orders", style: AppWidgets.boldTextFieldStyle()),
      ),
      drawer: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Drawer(
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
                                imgUrl =
                                    await controller.uploadImageToFirebase();
                              },
                              child: CircleAvatar(
                                radius: 50,
                                child: ClipOval(
                                  child: controller.image.value == null ||
                                          controller.image.value!.path.isEmpty
                                      ? (snapshot.data!.data()![
                                                      "profile_image"] ==
                                                  null ||
                                              snapshot.data!
                                                  .data()!["profile_image"]
                                                  .isEmpty
                                          ? Icon(Icons.person,
                                              size:
                                                  50) // Fallback when no image exists
                                          : Image.network(
                                              snapshot.data!
                                                  .data()!["profile_image"],
                                              fit: BoxFit.cover,
                                            ))
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
                            snapshot.data!.data()!["name"],
                            style: AppWidgets.semiBoldTextFieldStyle(),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.add_circled,
                          color: Color(0XFF8a4af3)),
                      title: const Text(
                        'Add Product',
                        style: TextStyle(color: Color(0XFF8a4af3)),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddFood()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.chat_bubble,
                          color: Color(0XFF8a4af3)),
                      title: const Text('Notification Screen',
                          style: TextStyle(color: Color(0XFF8a4af3))),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreens()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.cube_box,
                          color: Color(0XFF8a4af3)),
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
                      leading: const Icon(CupertinoIcons.arrow_right_square,
                          color: Color(0XFF8a4af3)),
                      title: const Text('Logout',
                          style: TextStyle(color: Color(0XFF8a4af3))),
                      onTap: signOut,
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: SizedBox());
            }
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("orders")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DateTime dateTime =
                    (snapshot.data!.docs[index]["timestamp"] as Timestamp)
                        .toDate();
                var orderDate = DateFormat('dd-MM-yyyy').format(dateTime);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: OrderUserListWidget(
                      userId: snapshot.data!.docs[index]["userId"],
                      expendedTile: ExpansionTile(
                        leading: Text("${index + 1}"),
                        title: Text(
                          orderDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                            snapshot.data!.docs[index]["paymentMethod"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black)),
                        trailing: Text(
                            "Total: ${snapshot.data!.docs[index]["totalAmount"]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black)),
                        children: [
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              itemCount:
                                  snapshot.data!.docs[index]["items"].length,
                              itemBuilder: (context, i) {
                                return ListTile(
                                  leading: Text("${i + 1}"),
                                  title: Text(
                                      snapshot.data!.docs[index]["items"][i]
                                          ["name"],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black)),
                                  subtitle: Row(
                                    children: [
                                      Text("Rs. " +
                                          snapshot.data!.docs[index]["items"][i]
                                              ["price"]),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Qty. " +
                                          snapshot.data!
                                              .docs[index]["items"][i]["count"]
                                              .toString()),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Product"),
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid)
                                                        .collection("orders")
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .get()
                                                        .then((docSnapshot) {
                                                      if (docSnapshot.exists) {
                                                        List items = docSnapshot
                                                            .data()!["items"];
                                                        items[i]["orderType"] =
                                                            "Reject";
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .collection(
                                                                "orders")
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .update({
                                                          "items": items
                                                        });
                                                      }
                                                    });
                                                    Navigator.pop(context);
                                                    FirebaseFirestore.instance
                                                        .collection("users")
                                                        .doc(snapshot.data!
                                                                .docs[index]
                                                            ["userId"])
                                                        .collection("orders")
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .get()
                                                        .then((docSnapshot) {
                                                      if (docSnapshot.exists) {
                                                        List items = docSnapshot
                                                            .data()!["items"];
                                                        items[i]["orderType"] =
                                                            "Reject";
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(snapshot.data!
                                                                    .docs[index]
                                                                ["userId"])
                                                            .collection(
                                                                "orders")
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .update({
                                                          "items": items
                                                        });
                                                      }
                                                    });
                                                  },
                                                  child: const Text("Reject"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid)
                                                        .collection("orders")
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .get()
                                                        .then((docSnapshot) {
                                                      if (docSnapshot.exists) {
                                                        List items = docSnapshot
                                                            .data()!["items"];
                                                        items[i]["orderType"] =
                                                            "Accept";
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .collection(
                                                                "orders")
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .update({
                                                          "items": items
                                                        });
                                                      }
                                                    });
                                                    Navigator.pop(context);
                                                    FirebaseFirestore.instance
                                                        .collection("users")
                                                        .doc(snapshot.data!
                                                                .docs[index]
                                                            ["userId"])
                                                        .collection("orders")
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .get()
                                                        .then((docSnapshot) {
                                                      if (docSnapshot.exists) {
                                                        List items = docSnapshot
                                                            .data()!["items"];
                                                        items[i]["orderType"] =
                                                            "Accept";
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(snapshot.data!
                                                                    .docs[index]
                                                                ["userId"])
                                                            .collection(
                                                                "orders")
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .update({
                                                          "items": items
                                                        });
                                                      }
                                                    });
                                                  },
                                                  child: const Text("Accept"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(snapshot.data!.docs[index]
                                        ["items"][i]["orderType"]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      phoneNumber: snapshot.data!.docs[index]["phoneNumber"],
                      address: snapshot.data!.docs[index]["currentAddress"],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
