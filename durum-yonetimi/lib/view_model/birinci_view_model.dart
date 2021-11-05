import 'package:durum_yonetimi/view/ikinci_sayfa.dart';
import 'package:durum_yonetimi/view_model/ikinci_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BirinciViewModel with ChangeNotifier {
  Color _renk = Colors.white;

  Color get renk => _renk;

  set renk(Color value) {
    _renk = value;
    notifyListeners();
  }

  String _yazi = "Merhaba";

  String get yazi => _yazi;

  set yazi(String value) {
    _yazi = value;
    notifyListeners();
  }

  bool _checkboxSeciliMi = false;

  bool get checkboxSeciliMi => _checkboxSeciliMi;

  set checkboxSeciliMi(bool value) {
    _checkboxSeciliMi = value;
    notifyListeners();
  }

  void butonaTiklandi() {
    yazi = "Butona Tıklandı";
  }

  void checkboxDegeriDegisti(bool? yeniDeger) {
    if (yeniDeger != null) {
      checkboxSeciliMi = yeniDeger;
    }
  }

  void renkDegistir() {
    renk = Colors.grey;
  }

void ikinciSayfayiAc(BuildContext context) {
  MaterialPageRoute sayfaYolu = MaterialPageRoute(
    builder: (BuildContext context) {
      return ChangeNotifierProvider(
        create: (BuildContext context) => IkinciViewModel(),
        child: IkinciSayfa(),
      );
    },
  );
  Navigator.pushReplacement(context, sayfaYolu);
}
}
