import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:yazar/repository/depolama_repository.dart';
import 'package:yazar/repository/kimlik_dogrulama_repository.dart';
import 'package:yazar/repository/veri_tabani_repository.dart';
import 'package:yazar/service/depolama_service_firebase.dart';
import 'package:yazar/service/kimlik_dogrulama_service_firebase.dart';
import 'package:yazar/service/veri_tabani_service_firestore.dart';
import 'package:yazar/service/veri_tabani_service_sqflite.dart';
import 'package:yazar/view/acilis_sayfasi.dart';
import 'package:yazar/view_model/acilis_view_model.dart';

GetIt locator = GetIt.instance;

setupLocator() {
  locator.registerLazySingleton(() => VeriTabaniRepository());
  locator.registerLazySingleton(() => FirestoreVeriTabaniService());
  locator.registerLazySingleton(() => SqfliteVeriTabaniService());

  locator.registerLazySingleton(() => KimlikDogrulamaRepository());
  locator.registerLazySingleton(() => FirebaseKimlikDogrulamaService());

  locator.registerLazySingleton(() => DepolamaRepository());
  locator.registerLazySingleton(() => FirebaseDepolamaService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (BuildContext context) => AcilisViewModel(),
        child: AcilisSayfasi(),
      ),
    );
  }
}
