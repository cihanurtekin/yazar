import 'package:flutter/material.dart';

class Kitap with ChangeNotifier {
  dynamic id;
  late DateTime olusturulmaTarihi;
  late String kullaniciId;

  late String _isim;

  String get isim => _isim;

  set isim(String value) {
    _isim = value;
    notifyListeners();
  }

  late int _kategori;

  int get kategori => _kategori;

  set kategori(int value) {
    _kategori = value;
    notifyListeners();
  }

  String? _resim;

  String? get resim => _resim;

  set resim(String? value) {
    _resim = value;
    notifyListeners();
  }

  bool _seciliMi = false;

  bool get seciliMi => _seciliMi;

  set seciliMi(bool value) {
    _seciliMi = value;
    notifyListeners();
  }

  Kitap(this._isim, this.olusturulmaTarihi, this._kategori, this.kullaniciId);

  Map<String, dynamic> mapeDonustur() {
    return {
      "isim": this._isim,
      "olusturulmaTarihi": olusturulmaTarihi,
      "kategori": this._kategori,
      "kullaniciId": this.kullaniciId,
      "resim": this._resim,
    };
  }

  Kitap.maptenOlustur(Map<String, dynamic> map) {
    this.id = map["id"];
    this._isim = map["isim"];
    this.olusturulmaTarihi = map["olusturulmaTarihi"];
    this._kategori = map["kategori"] ?? 0;
    this.kullaniciId = map["kullaniciId"];
    this._resim = map["resim"];
  }
}
