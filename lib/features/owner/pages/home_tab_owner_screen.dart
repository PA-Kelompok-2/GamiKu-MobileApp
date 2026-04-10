import 'package:flutter/material.dart';

class HomeTabKaryawan extends StatelessWidget {
  const HomeTabKaryawan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Karyawan")),
      body: const Center(
        child: Text(
          "Mode Karyawan 🔥",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
