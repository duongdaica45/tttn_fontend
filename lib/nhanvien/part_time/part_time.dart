import 'package:flutter/material.dart';

class PartScreen extends StatelessWidget {
  const PartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Part-time")),
      body: const Center(child: Text("Nhân viên Part-time")),
    );
  }
}
