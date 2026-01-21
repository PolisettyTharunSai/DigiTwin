import 'package:flutter/material.dart';

class EnterDetailsPage extends StatelessWidget {
  const EnterDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Details")),
      body: const Center(
        child: Text(
          "Put your form here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
