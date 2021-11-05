import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/main.dart';
import 'package:yazar/repository/kimlik_dogrulama_repository.dart';
import 'package:yazar/view/giris_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';
import 'package:yazar/view_model/giris_view_model.dart';
import 'package:yazar/view_model/kitaplar_view_model.dart';

class TelefonIleGirisViewModel with ChangeNotifier {
  final KimlikDogrulamaRepository _kimlikDogrulamaRepository =
      locator<KimlikDogrulamaRepository>();

  bool _dogrulamaBolumunuGoster = false;

  bool get dogrulamaBolumunuGoster => _dogrulamaBolumunuGoster;

  set dogrulamaBolumunuGoster(bool value) {
    _dogrulamaBolumunuGoster = value;
    notifyListeners();
  }

  dynamic _dogrulamaIdsi = "";

  void girisSayfasiniAc(BuildContext context) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => GirisViewModel(),
          child: GirisSayfasi(),
        );
      },
    );
    Navigator.pushReplacement(context, sayfaYolu);
  }

  void _kitaplarSayfasiniAc(BuildContext context) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => KitaplarViewModel(),
          child: KitaplarSayfasi(),
        );
      },
    );
    Navigator.pushReplacement(context, sayfaYolu);
  }

  void dogrulamaKoduGonder(
    BuildContext context,
    String telefonNumarasi,
  ) async {
    if (telefonNumarasi.isNotEmpty) {
      await _kimlikDogrulamaRepository.telefonDogrulamaKoduGonder(
        telefonNumarasi,
        otomatikDogrulama: (kullaniciId) {
          _otomatikDogrulama(context, kullaniciId);
        },
        dogrulamaBasarisiz: _dogrulamaBasarisiz,
        dogrulamaKoduGonderildi: _dogrulamaKoduGonderildi,
        kodZamanAsimi: _kodZamanAsimi,
      );
    }
  }

  void _otomatikDogrulama(BuildContext context, kullaniciId) async {
    if (kullaniciId != null) {
      print("Telefon Numarası ile giriş başarılı.");
      _kitaplarSayfasiniAc(context);
    }
  }

  void _dogrulamaBasarisiz(String hata) {
    if (hata == 'invalid-phone-number') {
      print("Telefon numarası geçersiz.");
    } else {
      print("İşlem başarısız.");
    }
  }

  void _dogrulamaKoduGonderildi(dogrulamaIdsi) {
    _dogrulamaIdsi = dogrulamaIdsi;
    dogrulamaBolumunuGoster = true;
  }

  void _kodZamanAsimi() {
    print("Doğrulama kodu zaman aşımına uğradı.");
  }

  void dogrulamaKodunuOnayla(
    BuildContext context,
    String dogrulamaKodu,
  ) async {
    if (_dogrulamaIdsi.isNotEmpty && dogrulamaKodu.isNotEmpty) {
      dynamic kullaniciId = await _kimlikDogrulamaRepository
          .telefonDogrulamaKodunuOnayla(_dogrulamaIdsi, dogrulamaKodu);
      if (kullaniciId != null) {
        _kitaplarSayfasiniAc(context);
      }
    }
  }
}
