import 'package:flutter/material.dart';

void main() {
  runApp(const IconGeneratorApp());
}

class IconGeneratorApp extends StatelessWidget {
  const IconGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Icon Generator')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Right-click the icon below and "Save Image As"'),
              Text('Save it as "app_icon.png" in assets/icons/ folder'),
              SizedBox(height: 20),
              IconDisplay(),
            ],
          ),
        ),
      ),
    );
  }
}

class IconDisplay extends StatelessWidget {
  const IconDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 512,
      height: 512,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.eco_rounded,
        size: 300,
        color: Colors.white,
      ),
    );
  }
}
