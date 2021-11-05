import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  TextEditingController _sifreController = TextEditingController();

  String _mevcutSifre = "";

  @override
  void initState() {
    super.initState();
    _sifreyiGetir();
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _mevcutSifre.isNotEmpty
                ? "Mevcut Şifrenizle\nGiriş Yapın"
                : "Hoşgeldiniz!\nBir Şifre Belirleyin",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _sifreController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: "Şifreyi giriniz"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text(_mevcutSifre.isNotEmpty ? "Giriş Yap" : "Kaydet"),
            onPressed: () {
              if (_mevcutSifre.isNotEmpty) {
                _girisYap(context);
              } else {
                _sifreyiKaydet(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _sifreyiKaydet(BuildContext context) async {
    String girilenSifre = _sifreController.text;
    if (girilenSifre.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("sifre", girilenSifre);
      _kitaplarSayfasiniAc(context);
    }
  }

  void _sifreyiGetir() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String okunanDeger = await prefs.getString("sifre") ?? "";
    setState(() {
      _mevcutSifre = okunanDeger;
    });
  }

  void _girisYap(BuildContext context) {
    if (_sifreController.text == _mevcutSifre) {
      _kitaplarSayfasiniAc(context);
    }
  }

  void _kitaplarSayfasiniAc(BuildContext context) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return KitaplarSayfasi();
      },
    );
    Navigator.pushReplacement(context, sayfaYolu);
  }
}
