import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/main.dart';
import 'package:yazar/repository/kimlik_dogrulama_repository.dart';
import 'package:yazar/view/giris_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';
import 'package:yazar/view_model/giris_view_model.dart';
import 'package:yazar/view_model/kitaplar_view_model.dart';

class AcilisViewModel with ChangeNotifier {
  final KimlikDogrulamaRepository _kimlikDogrulamaRepository =
      locator<KimlikDogrulamaRepository>();

  yonlendir(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      dynamic kullaniciId =
          await _kimlikDogrulamaRepository.kullaniciIdsiniGetir();

      if (kullaniciId != null) {
        _kitaplarSayfasiniAc(context);
      } else {
        _girisSayfasiniAc(context);
      }
    });
  }

  void _girisSayfasiniAc(BuildContext context) {
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
}
