import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:yazar/view/kayit_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';
import 'package:yazar/view/telefon_ile_giris_sayfasi.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  TextEditingController _epostaController = TextEditingController();
  TextEditingController _sifreController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giriş Sayfası"),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 32, left: 16, right: 16),
      child: Column(
        children: [
          TextField(
            controller: _epostaController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "E-posta",
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _sifreController,
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Şifre",
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Giriş Yap"),
              onPressed: () {
                _epostaVeSifreIleGiris(context);
              },
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Hesabınız yok mu? Kayıt olun"),
              onPressed: () {
                _kayitSayfasiniAc(context);
              },
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            child: Text(
              "Şifremi unuttum",
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onPressed: () {
              _sifreSifirla(context);
            },
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Google ile giriş"),
              onPressed: () {
                _googleIleGiris(context);
              },
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Apple ile giriş"),
              onPressed: () {
                _appleIleGiris(context);
              },
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Telefon numarası ile giriş"),
              onPressed: () {
                _telefonNumarasiIleGiris(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _kayitSayfasiniAc(BuildContext context) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return KayitSayfasi();
      },
    );
    Navigator.pushReplacement(context, sayfaYolu);
  }

  void _kitaplarSayfasiniAc(BuildContext context) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return KitaplarSayfasi();
      },
    );
    Navigator.pushReplacement(context, sayfaYolu);
  }

  void _epostaVeSifreIleGiris(BuildContext context) async {
    String eposta = _epostaController.text.trim();
    String sifre = _sifreController.text.trim();

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

  void _googleIleGiris(BuildContext context) async {
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

  void _appleIleGiris(BuildContext context) async {
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

  void _telefonNumarasiIleGiris(BuildContext context) async {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return TelefonIleGirisSayfasi();
      },
    );
    Navigator.pushReplacement(context, sayfaYolu);
  }

  void _sifreSifirla(BuildContext context) async {
    String eposta = _epostaController.text.trim();

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
