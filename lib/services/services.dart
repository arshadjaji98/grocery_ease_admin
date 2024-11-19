import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends GetxController {
  Rx<File?> image = Rx<File?>(null); // Nullable Rx<File>

  Future pickImage() async {
    try {
      final imagePick =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (imagePick == null) {
        return;
      }
      final imageTemp = File(imagePick.path);
      image.value = imageTemp; // Assign File to Rx<File?>
    } on PlatformException catch (e) {
      return e;
    }
  }

  Future pickImageCamera() async {
    try {
      final imagePick =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (imagePick == null) {
        return;
      }
      final imageTemp = File(imagePick.path);
      image.value = imageTemp; // Assign File to Rx<File?>
    } on PlatformException catch (e) {
      return e;
    }
  }

  Rx<String> networkImage = ''.obs;

  Future<String> uploadImageToFirebase() async {
    if (image.value == null) {
      return '';
    }
    String fireName = DateTime.now().microsecondsSinceEpoch.toString();
    try {
      Reference reference =
          FirebaseStorage.instance.ref().child('adminpictures/$fireName.png');
      await reference.putFile(image.value!);
      String downloadUrl = await reference.getDownloadURL();
      networkImage.value = downloadUrl;
      print("Download URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      return '';
    }
  }
}
