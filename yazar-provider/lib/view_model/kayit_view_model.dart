import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/view/giris_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';
import 'package:yazar/view_model/giris_view_model.dart';
import 'package:yazar/view_model/kitaplar_view_model.dart';

class KayitViewModel with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

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
    try {
      UserCredential kullaniciKimligi =
          await _auth.createUserWithEmailAndPassword(
        email: eposta,
        password: sifre,
      );

      User? kullanici = kullaniciKimligi.user;
      await kullanici?.updateDisplayName(adSoyad);
      await kullanici?.sendEmailVerification();

      _kitaplarSayfasiniAc(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        _snackbarGoster(context, "Parola çok zayıf.");
      } else if (e.code == "email-already-in-use") {
        _snackbarGoster(
          context,
          "Bu e-posta ile daha önce hesap oluşturulmuş.",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _snackbarGoster(BuildContext context, String mesaj) {
    SnackBar snackBar = SnackBar(content: Text(mesaj));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
