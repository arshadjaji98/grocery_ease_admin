import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/widgets/text_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> fooditems = [
    'Fruit',
    'Meat',
    'Beverages',
    'Backery',
    'Oil',
    'Vegetables',
    'Dry Fruits',
    'Snacks',
    'Honey'
  ];
  String? value;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    selectedImage = File(image!.path);
    setState(() {});
  }

  bool isLoading = false;

  uploadItem() async {
    if (selectedImage != null &&
        nameController.text != "" &&
        priceController.text != "" &&
        detailController.text != "" &&
        quantityController.text != "") {
      setState(() {
        isLoading = true; // Start loading when the upload starts
      });

      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("blogImages").child(addId);

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downloadUrl = await (await task).ref.getDownloadURL();

      var productId = FirebaseFirestore.instance.collection("products").doc();

      Map<String, dynamic> addItem = {
        "image": downloadUrl,
        "name": nameController.text,
        "price": priceController.text,
        "quantity": quantityController.text,
        "detail": detailController.text,
        "date": DateTime.now(),
        "adminId": FirebaseAuth.instance.currentUser!.uid,
        "type": value,
        "id": productId.id,
        "favourite": [],
      };

      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId.id)
          .set(addItem)
          .then((value) {
        // After upload completes, reset the loading state
        setState(() {
          isLoading = false; // Stop loading
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Food Item has been added Successfully",
              style: TextStyle(fontSize: 18.0),
            )));

        // Clear all fields after upload
        nameController.clear();
        priceController.clear();
        detailController.clear();
        quantityController.clear();
        selectedImage = null;
        this.value = null;

        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF373866),
            )),
        centerTitle: true,
        title: Text(
          "Add Item",
          style: AppWidgets.headerTextFieldStyle(),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload the Item Picture",
                style: AppWidgets.semiBoldTextFieldStyle(),
              ),
              const SizedBox(
                height: 20.0,
              ),
              selectedImage == null
                  ? GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Center(
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        // Allow the user to select a new image after tapping the displayed image
                        getImage();
                      },
                      child: Center(
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 30.0,
              ),
              Text(
                "Item Name",
                style: AppWidgets.semiBoldTextFieldStyle(),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Item Name",
                      hintStyle: AppWidgets.lightTextFieldStyle()),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Text(
                "Item Price",
                style: AppWidgets.semiBoldTextFieldStyle(),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Item Price",
                      hintStyle: AppWidgets.lightTextFieldStyle()),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Text(
                "Item Detail",
                style: AppWidgets.semiBoldTextFieldStyle(),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  maxLines: 6,
                  controller: detailController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Item Detail",
                      hintStyle: AppWidgets.semiBoldTextFieldStyle()),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Select Category",
                style: AppWidgets.semiBoldTextFieldStyle(),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Quantity",
                    hintStyle: AppWidgets.semiBoldTextFieldStyle(),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                  items: fooditems
                      .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                                fontSize: 18.0, color: Colors.black),
                          )))
                      .toList(),
                  onChanged: ((value) => setState(() {
                        this.value = value;
                      })),
                  dropdownColor: Colors.white,
                  hint: const Text("Select Category"),
                  iconSize: 36,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  value: value,
                )),
              ),
              const SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                onTap: isLoading ? null : uploadItem,
                child: Center(
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Add",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
