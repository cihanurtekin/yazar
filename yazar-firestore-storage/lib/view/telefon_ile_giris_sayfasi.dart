import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yazar/view/giris_sayfasi.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';

class TelefonIleGirisSayfasi extends StatefulWidget {
  @override
  State<TelefonIleGirisSayfasi> createState() => _TelefonIleGirisSayfasiState();
}

class _TelefonIleGirisSayfasiState extends State<TelefonIleGirisSayfasi> {
  TextEditingController _telefonNumarasiController = TextEditingController();

  TextEditingController _dogrulamaKoduController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  bool _dogrulamaBolumunuGoster = false;

  String _dogrulamaIdsi = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Telefon Numarası ile Giriş"),
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
            controller: _telefonNumarasiController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Telefon numarası",
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Doğrulama kodu gönder"),
              onPressed: _dogrulamaKoduGonder,
            ),
          ),
          SizedBox(height: 48),
          Visibility(
            visible: _dogrulamaBolumunuGoster,
            child: Column(
              children: [
                TextField(
                  controller: _dogrulamaKoduController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Doğrulama kodu",
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("Doğrulama kodunu onayla"),
                    onPressed: () {
                      _dogrulamaKodunuOnayla(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Diğer giriş yöntemleri"),
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

  void _snackbarGoster(BuildContext context, String mesaj) {
    SnackBar snackBar = SnackBar(content: Text(mesaj));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _dogrulamaKoduGonder() async {
    String telefonNumarasi = _telefonNumarasiController.text.trim();

    if (telefonNumarasi.isNotEmpty) {
      await _auth.verifyPhoneNumber(
        phoneNumber: telefonNumarasi,
        verificationCompleted: _otomatikDogrulama,
        verificationFailed: _dogrulamaBasarisiz,
        codeSent: _dogrulamaKoduGonderildi,
        codeAutoRetrievalTimeout: _kodZamanAsimi,
      );
    }
  }

  void _otomatikDogrulama(PhoneAuthCredential dogrulamaKimligi) async {
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

    setState(() {
      _dogrulamaBolumunuGoster = true;
    });
  }

  void _kodZamanAsimi(String verificationId) {
    print("Doğrulama kodu zaman aşımına uğradı.");
  }

  void _dogrulamaKodunuOnayla(BuildContext context) async {
    String dogrulamaKodu = _dogrulamaKoduController.text.trim();

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
