import 'dart:io';

abstract class DepolamaBase {
  Future<String> dosyaYukle(String dosyaYolu, File dosya);
}
