import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/repository/kimlik_dogrulama_repository.dart';
import 'package:yazar/view/giris_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';
import 'package:yazar/view_model/giris_view_model.dart';
import 'package:yazar/view_model/kitaplar_view_model.dart';

import '../main.dart';

class KayitViewModel with ChangeNotifier {
  final KimlikDogrulamaRepository _kimlikDogrulamaRepository =
      locator<KimlikDogrulamaRepository>();

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

  void epostaVeSifreIleKayit(
    BuildContext context,
    String adSoyad,
    String eposta,
    String sifre,
  ) async {
    dynamic kullaniciId = await _kimlikDogrulamaRepository
        .epostaVeSifreIleKayit(adSoyad, eposta, sifre);
    if (kullaniciId != null) {
      _kitaplarSayfasiniAc(context);
    }
  }

  void _snackbarGoster(BuildContext context, String mesaj) {
    SnackBar snackBar = SnackBar(content: Text(mesaj));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
