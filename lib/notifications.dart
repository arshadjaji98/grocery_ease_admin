import 'package:flutter/material.dart';

class NotificationsScreens extends StatefulWidget {
  const NotificationsScreens({super.key});

  @override
  State<NotificationsScreens> createState() => _NotificationsScreensState();
}

class _NotificationsScreensState extends State<NotificationsScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
        title: const Text("Chat Screen"),
      ),
    );
  }
}
