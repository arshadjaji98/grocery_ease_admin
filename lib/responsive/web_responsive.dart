import 'package:flutter/material.dart';

class WebResponsive extends StatelessWidget {
  final Widget child;
  const WebResponsive({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600), child: child),
    );
  }
}
