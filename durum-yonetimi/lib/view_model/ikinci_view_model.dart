import 'package:durum_yonetimi/model/siparis.dart';
import 'package:flutter/material.dart';

class IkinciViewModel with ChangeNotifier {
  List<Siparis> siparisler = [];

  IkinciViewModel() {
    for (int i = 1; i <= 5; i++) {
      Siparis siparis = Siparis("Sipariş $i", "Onay Bekliyor...");
      siparisler.add(siparis);
    }
  }

void siparisOnayla(Siparis siparis) {
  int index = siparisler.indexWhere((s) => s.baslik == siparis.baslik);
  siparisler[index].durum = "Onaylandı";
  notifyListeners();
}
}
