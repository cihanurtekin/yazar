import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/view/giris_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';
import 'package:yazar/view_model/giris_view_model.dart';
import 'package:yazar/view_model/kitaplar_view_model.dart';

class TelefonIleGirisViewModel with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool _dogrulamaBolumunuGoster = false;

  bool get dogrulamaBolumunuGoster => _dogrulamaBolumunuGoster;

  set dogrulamaBolumunuGoster(bool value) {
    _dogrulamaBolumunuGoster = value;
    notifyListeners();
  }

  String _dogrulamaIdsi = "";

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

  void _snackbarGoster(BuildContext context, String mesaj) {
    SnackBar snackBar = SnackBar(content: Text(mesaj));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void dogrulamaKoduGonder(
    BuildContext context,
    String telefonNumarasi,
  ) async {
    if (telefonNumarasi.isNotEmpty) {
      await _auth.verifyPhoneNumber(
        phoneNumber: telefonNumarasi,
        verificationCompleted: (PhoneAuthCredential dogrulamaKimligi) {
          _otomatikDogrulama(context, dogrulamaKimligi);
        },
        verificationFailed: _dogrulamaBasarisiz,
        codeSent: _dogrulamaKoduGonderildi,
        codeAutoRetrievalTimeout: _kodZamanAsimi,
      );
    }
  }

  void _otomatikDogrulama(
    BuildContext context,
    PhoneAuthCredential dogrulamaKimligi,
  ) async {
    UserCredential kullaniciKimligi = await _auth.signInWithCredential(
      dogrulamaKimligi,
    );

    User? kullanici = kullaniciKimligi.user;
    if (kullanici != null) {
      print("Telefon Numarası ile giriş başarılı.");
      _kitaplarSayfasiniAc(context);
    }
  }

  void _dogrulamaBasarisiz(FirebaseAuthException e) {
    if (e.code == 'invalid-phone-number') {
      print("Telefon numarası geçersiz.");
    } else {
      print("İşlem başarısız.");
    }
  }

  void _dogrulamaKoduGonderildi(String verificationId, int? resendToken) {
    _dogrulamaIdsi = verificationId;
    dogrulamaBolumunuGoster = true;
  }

  void _kodZamanAsimi(String verificationId) {
    print("Doğrulama kodu zaman aşımına uğradı.");
  }

  void dogrulamaKodunuOnayla(
    BuildContext context,
    String dogrulamaKodu,
  ) async {
    if (_dogrulamaIdsi.isNotEmpty && dogrulamaKodu.isNotEmpty) {
      try {
        PhoneAuthCredential dogrulamaKimligi = PhoneAuthProvider.credential(
          verificationId: _dogrulamaIdsi,
          smsCode: dogrulamaKodu,
        );

        UserCredential kullaniciKimligi = await _auth.signInWithCredential(
          dogrulamaKimligi,
        );

        User? kullanici = kullaniciKimligi.user;

        if (kullanici != null) {
          _snackbarGoster(context, "Telefon Numarası ile giriş başarılı.");
          _kitaplarSayfasiniAc(context);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == "invalid-verification-code") {
          _snackbarGoster(context, "Doğrulama kodu geçersiz.");
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
