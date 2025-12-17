import 'package:flutter/material.dart';

void main() {
  runApp(const ColorYourMindApp());
}

class ColorYourMindApp extends StatelessWidget {
  const ColorYourMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Your Mind',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ColoringBookHomePage(title: 'Color Your Mind'),
    );
  }
}

class ColoringBookHomePage extends StatefulWidget {
  const ColoringBookHomePage({super.key, required this.title});

  final String title;

  @override
  State<ColoringBookHomePage> createState() => _ColoringBookHomePageState();
}

class _ColoringBookHomePageState extends State<ColoringBookHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.palette,
              size: 100,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Color Your Mind!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'A coloring book app for mobile and web',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
