import 'package:flutter/material.dart';

class KaryawanScreen extends StatelessWidget {
  const KaryawanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karyawan')),
      body: const Center(child: Text('Karyawan Page')),
    );
  }
}
