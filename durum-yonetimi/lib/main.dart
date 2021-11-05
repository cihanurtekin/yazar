import 'package:durum_yonetimi/view/birinci_sayfa.dart';
import 'package:durum_yonetimi/view_model/birinci_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (BuildContext context) => BirinciViewModel(),
        child: BirinciSayfa(),
      ),
    );
  }
}

/*
@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => BirinciViewModel(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => IkinciViewModel(),
        ),
      ],
      child: BirinciSayfa(),
    ),
  );
}
*/