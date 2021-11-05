import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:yazar/view/kayit_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';
import 'package:yazar/view/telefon_ile_giris_sayfasi.dart';
import 'package:yazar/view_model/kayit_view_model.dart';
import 'package:yazar/view_model/kitaplar_view_model.dart';
import 'package:yazar/view_model/telefon_ile_giris_view_model.dart';

class GirisViewModel with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

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
    try {
      UserCredential kullaniciKimligi = await _auth.signInWithEmailAndPassword(
        email: eposta,
        password: sifre,
      );

      User? kullanici = kullaniciKimligi.user;
      if (kullanici != null) {
        _snackbarGoster(context, "Giriş başarılı.");
        print(_auth.currentUser?.emailVerified ?? 'Kayıt yok');
        _kitaplarSayfasiniAc(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        _snackbarGoster(context, "Kullanıcı bulunamadı.");
      } else if (e.code == "wrong-password") {
        _snackbarGoster(context, "Yanlış şifre girdiniz.");
      }
    } catch (e) {
      print(e);
    }
  }

  void googleIleGiris(BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ["email"]);

    GoogleSignInAccount? googleKullanici = await googleSignIn.signIn();

    if (googleKullanici != null) {
      GoogleSignInAuthentication googleKimlik =
          await googleKullanici.authentication;

      AuthCredential dogrulamaKimligi = GoogleAuthProvider.credential(
        accessToken: googleKimlik.accessToken,
        idToken: googleKimlik.idToken,
      );
      UserCredential kullaniciKimligi = await _auth.signInWithCredential(
        dogrulamaKimligi,
      );

      User? kullanici = kullaniciKimligi.user;
      if (kullanici != null) {
        _snackbarGoster(context, "Google ile giriş başarılı.");
        _kitaplarSayfasiniAc(context);
      }
    }
  }

  void appleIleGiris(BuildContext context) async {
    AuthorizationCredentialAppleID appleKimlik =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
      ],
    );

    OAuthProvider oAuthProvider = OAuthProvider("apple.com");

    AuthCredential dogrulamaKimligi = oAuthProvider.credential(
      accessToken: appleKimlik.authorizationCode,
      idToken: appleKimlik.identityToken,
    );
    UserCredential kullaniciKimligi = await _auth.signInWithCredential(
      dogrulamaKimligi,
    );

    User? kullanici = kullaniciKimligi.user;
    if (kullanici != null) {
      _snackbarGoster(context, "Apple ile giriş başarılı.");
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
      await _auth.sendPasswordResetEmail(email: eposta);
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
