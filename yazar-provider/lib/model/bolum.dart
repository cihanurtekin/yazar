import 'package:flutter/material.dart';

class Bolum with ChangeNotifier {
  dynamic id;
  dynamic kitapId;
  late String icerik;
  late String kullaniciId;

  late String _baslik;

  String get baslik => _baslik;

  set baslik(String value) {
    _baslik = value;
    notifyListeners();
  }

  Bolum(this.kitapId, this._baslik, this.kullaniciId) {
    icerik = "";
  }

  Map<String, dynamic> mapeDonustur() {
    return {
      "kitapId": this.kitapId,
      "baslik": this._baslik,
      "icerik": this.icerik,
      "olusturulmaTarihi": DateTime.now(),
      "kullaniciId": this.kullaniciId,
    };
  }

  Bolum.maptenOlustur(Map<String, dynamic> map) {
    this.id = map["id"];
    this.kitapId = map["kitapId"];
    this._baslik = map["baslik"];
    this.icerik = map["icerik"];
    this.kullaniciId = map["kullaniciId"];
  }
}
