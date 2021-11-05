import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/main.dart';
import 'package:yazar/repository/kimlik_dogrulama_repository.dart';
import 'package:yazar/view/kayit_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';
import 'package:yazar/view/telefon_ile_giris_sayfasi.dart';
import 'package:yazar/view_model/kayit_view_model.dart';
import 'package:yazar/view_model/kitaplar_view_model.dart';
import 'package:yazar/view_model/telefon_ile_giris_view_model.dart';

class GirisViewModel with ChangeNotifier {
  final KimlikDogrulamaRepository _kimlikDogrulamaRepository =
      locator<KimlikDogrulamaRepository>();

  void kayitSayfasiniAc(BuildContext context) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => KayitViewModel(),
          child: KayitSayfasi(),
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

  void epostaVeSifreIleGiris(
    BuildContext context,
    String eposta,
    String sifre,
  ) async {
    dynamic kullaniciId =
        await _kimlikDogrulamaRepository.epostaVeSifreIleGiris(eposta, sifre);
    if (kullaniciId != null) {
      _kitaplarSayfasiniAc(context);
    }
  }

  void googleIleGiris(BuildContext context) async {
    dynamic kullaniciId = await _kimlikDogrulamaRepository.googleIleGiris();
    if (kullaniciId != null) {
      _kitaplarSayfasiniAc(context);
    }
  }

  void appleIleGiris(BuildContext context) async {
    dynamic kullaniciId = await _kimlikDogrulamaRepository.appleIleGiris();
    if (kullaniciId != null) {
      _kitaplarSayfasiniAc(context);
    }
  }

  void telefonNumarasiIleGiris(BuildContext context) async {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => TelefonIleGirisViewModel(),
          child: TelefonIleGirisSayfasi(),
        );
      },
    );
    Navigator.pushReplacement(context, sayfaYolu);
  }

  void sifreSifirla(BuildContext context, String eposta) async {
    if (eposta.isNotEmpty) {
      await _kimlikDogrulamaRepository.sifreSifirla(eposta);
      _snackbarGoster(context, "Şifre sıfırlama bağlantısı gönderildi.");
    } else {
      _snackbarGoster(context, "Lütfen e-posta adresinizi girin.");
    }
  }

  void _snackbarGoster(BuildContext context, String mesaj) {
    SnackBar snackBar = SnackBar(content: Text(mesaj));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
