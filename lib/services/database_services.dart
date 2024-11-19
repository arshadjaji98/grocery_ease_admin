import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Adds user details to the 'users' collection with a specified document ID.
  Future<void> addUserDetail(
      Map<String, dynamic> userInfoMap, String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(userInfoMap);
  }

  // Adds a food item to a specified collection (e.g., a category name).
  Future<void> addFoodItem(
      Map<String, dynamic> foodItemMap, String categoryName) async {
    await FirebaseFirestore.instance.collection(categoryName).add(foodItemMap);
  }

  Stream<QuerySnapshot> getFoodItem(String categoryName) {
    return FirebaseFirestore.instance.collection(categoryName).snapshots();
  }

  // Adds a food item to a specific user's 'Cart' subcollection.
  Future<void> addFoodToCart(
      Map<String, dynamic> foodItemMap, String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .add(foodItemMap);
  }

  // Searches for users by the first letter of the username (case-insensitive).
  Future<QuerySnapshot> searchUserByUsername(String username) async {
    String searchKey = username.substring(0, 1).toUpperCase();
    return await FirebaseFirestore.instance
        .collection('users')
        .where('SearchKey', isEqualTo: searchKey)
        .get();
  }

  // Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
