import 'package:flutter/material.dart';

class OwnerScreen extends StatelessWidget {
  const OwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner')),
      body: const Center(child: Text('Owner Dashboard')),
    );
  }
}
