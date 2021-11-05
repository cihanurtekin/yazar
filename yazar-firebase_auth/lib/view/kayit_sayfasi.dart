import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yazar/view/giris_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';

class KayitSayfasi extends StatefulWidget {
  @override
  _KayitSayfasiState createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends State<KayitSayfasi> {
  TextEditingController _adSoyadController = TextEditingController();
  TextEditingController _epostaController = TextEditingController();
  TextEditingController _sifreController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kayıt Sayfası"),
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
            controller: _adSoyadController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Ad - Soyad",
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _epostaController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "E - posta",
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
              child: Text("Kayıt Ol"),
              onPressed: () {
                _epostaVeSifreIleKayit(context);
              },
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Zaten hesabınız var mı? Giriş yapın"),
              onPressed: () {
                _girisSayfasiniAc(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _girisSayfasiniAc(BuildContext context) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return GirisSayfasi();
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

  void _epostaVeSifreIleKayit(BuildContext context) async {
    String adSoyad = _adSoyadController.text.trim();
    String eposta = _epostaController.text.trim();
    String sifre = _sifreController.text.trim();

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
            context, "Bu e-posta ile daha önce hesap oluşturulmuş.");
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
