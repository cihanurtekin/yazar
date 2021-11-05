import 'dart:io';

import 'package:yazar/base/depolama_base.dart';
import 'package:yazar/main.dart';
import 'package:yazar/service/base/depolama_service.dart';
import 'package:yazar/service/depolama_service_firebase.dart';

class DepolamaRepository implements DepolamaBase {
  final DepolamaService _service = locator<FirebaseDepolamaService>();

  @override
  Future<String> dosyaYukle(String dosyaYolu, File dosya) async {
    return await _service.dosyaYukle(dosyaYolu, dosya);
  }
}
