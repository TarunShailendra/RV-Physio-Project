import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.routeName, super.key});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(routeName)));
  }
}
