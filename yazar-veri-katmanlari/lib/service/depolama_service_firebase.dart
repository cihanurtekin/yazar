import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:yazar/service/base/depolama_service.dart';

class FirebaseDepolamaService implements DepolamaService {
  FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> dosyaYukle(String dosyaYolu, File dosya) async {
    TaskSnapshot yukleme = await _storage.ref(dosyaYolu).putFile(dosya);
    return await yukleme.ref.getDownloadURL();
  }
}
