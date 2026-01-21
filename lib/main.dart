import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const WheatApp());
}

class WheatApp extends StatelessWidget {
  const WheatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Wheat",
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const HomePage(),
    );
  }
}
