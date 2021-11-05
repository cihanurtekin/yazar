import 'package:flutter/material.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/veri_tabani/uzak_veri_tabani.dart';
import 'package:yazar/veri_tabani/yerel_veri_tabani.dart';

class BolumDetayViewModel with ChangeNotifier {
  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();
  UzakVeriTabani _uzakVeriTabani = UzakVeriTabani();

  final Bolum bolum;

  BolumDetayViewModel(this.bolum);

  void icerigiKaydet(String icerik) async {
    bolum.icerik = icerik;
    await _uzakVeriTabani.updateBolum(bolum);
  }
}
