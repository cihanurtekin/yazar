import 'package:flutter/material.dart';
import 'package:yazar/main.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/repository/veri_tabani_repository.dart';

class BolumDetayViewModel with ChangeNotifier {
  final VeriTabaniRepository _veriTabaniRepository =
      locator<VeriTabaniRepository>();

  final Bolum bolum;

  BolumDetayViewModel(this.bolum);

  void icerigiKaydet(String icerik) async {
    bolum.icerik = icerik;
    await _veriTabaniRepository.updateBolum(bolum);
  }
}
