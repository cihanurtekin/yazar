import 'package:flutter/material.dart';
import 'package:yazar/view/giris_sayfasi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GirisSayfasi(),
    );
  }
}