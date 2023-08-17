// main.dart

import 'package:flutter/material.dart';
import 'screens/iron_man_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Premiere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
        ),
      ),
      home: IronManScreen(),
    );
  }
}
