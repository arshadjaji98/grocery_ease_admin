import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderUserListWidget extends StatefulWidget {
  const OrderUserListWidget({
    required this.userId,
    required this.expendedTile,
    required this.phoneNumber,
    required this.address,
    super.key, 
    required this.fullName, 
    required this.city,
  });

  final String userId;
  final String phoneNumber;
  final String fullName;
  final String city;
  final String address;
  final Widget expendedTile;

  @override
  State<OrderUserListWidget> createState() => _OrderUserListWidgetState();
}

class _OrderUserListWidgetState extends State<OrderUserListWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("users").doc(widget.userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User data not found"));
        }


        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoText("Name", widget.fullName),
                        _buildInfoText("Mobile Number", widget.phoneNumber),
                        _buildInfoText("Confirm Address", widget.address),
                        _buildInfoText("City", widget.city),
                      ],
                    ),
                  ),
                ],
              ),
             
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Text(
      "$label: $value",
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
