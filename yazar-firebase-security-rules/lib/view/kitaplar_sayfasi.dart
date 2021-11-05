import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/sabitler.dart';
import 'package:yazar/veri_tabani/uzak_veri_tabani.dart';
import 'package:yazar/veri_tabani/yerel_veri_tabani.dart';
import 'package:yazar/view/bolumler_sayfasi.dart';
import 'package:yazar/view/giris_sayfasi.dart';

class KitaplarSayfasi extends StatefulWidget {
  @override
  State<KitaplarSayfasi> createState() => _KitaplarSayfasiState();
}

class _KitaplarSayfasiState extends State<KitaplarSayfasi> {
  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();
  UzakVeriTabani _uzakVeriTabani = UzakVeriTabani();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  List<Kitap> _kitaplar = [];
  DocumentSnapshot<Map<String, dynamic>>? _sonKitapDokumani;

  List<int> _tumKategoriler = [-1];
  int _secilenKategori = -1;

  List<String> _secilenKitapIdleri = [];

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tumKategoriler.addAll(Sabitler.kategoriler.keys);
    _scrollController.addListener(_kaydirmaKontrol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kitaplar Sayfası"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _seciliKitaplariSil,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _cikisYap(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _kitapEkle(context);
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<void>(
      future: _ilkKitaplariGetir(),
      builder: _buildListView,
    );
  }

  Widget _buildListView(BuildContext context, AsyncSnapshot<void> snapshot) {
    return Column(
      children: [
        _kategoriFiltresi(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _kitaplar.length,
            itemBuilder: _buildListTile,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, int index) {
    return ListTile(
      leading: SizedBox(
        width: 48,
        height: 48,
        child: Image.network(
          _kitaplar[index].resim ??
              "https://firebasestorage.googleapis.com"
                  "/v0/b/yazar-d3654.appspot.com/o"
                  "/flutter_logo.jpg?alt=media&token="
                  "6b76a533-397b-4d87-8e9f-f4a481e52f27",
          fit: BoxFit.cover,
        ),
      ),
      title: Text(_kitaplar[index].isim),
      subtitle: Text(Sabitler.kategoriler[_kitaplar[index].kategori] ?? ""),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              _resimEkle(context, index);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _kitapGuncelle(context, index);
            },
          ),
          Checkbox(
            value: _secilenKitapIdleri.contains(_kitaplar[index].id),
            onChanged: (bool? yeniDeger) {
              setState(() {
                if (yeniDeger != null) {
                  String? kitapId = _kitaplar[index].id;
                  if (kitapId != null) {
                    if (yeniDeger) {
                      _secilenKitapIdleri.add(kitapId);
                    } else {
                      _secilenKitapIdleri.remove(_kitaplar[index].id);
                    }
                  }
                }
              });
            },
          ),
        ],
      ),
      onTap: () {
        _bolumlerSayfasiniAc(context, index);
      },
    );
  }

  Widget _kategoriFiltresi() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Kategori:",
          style: TextStyle(fontSize: 16),
        ),
        DropdownButton(
          value: _secilenKategori,
          onChanged: (int? yeniSecilenKategori) {
            _kitaplar = [];
            setState(() {});
            if (yeniSecilenKategori != null) {
              setState(() {
                _secilenKategori = yeniSecilenKategori;
              });
            }
          },
          items: _tumKategoriler.map<DropdownMenuItem<int>>(
            (kategoriId) {
              return DropdownMenuItem<int>(
                value: kategoriId,
                child: Text(kategoriId == -1
                    ? "Hepsi"
                    : Sabitler.kategoriler[kategoriId] ?? ""),
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  void _kaydirmaKontrol() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      _sonrakiKitaplariGetir();
    }
  }

  void _kitapEkle(BuildContext context) async {
    String? kullaniciId = _auth.currentUser?.uid;

    if (kullaniciId != null) {
      List<dynamic> sonuc =
          await _pencereAc(context, "Kitap Adını Giriniz") ?? [];

      if (sonuc.isNotEmpty) {
        String kitapAdi = sonuc[0];
        int kategori = sonuc[1];

        if (kitapAdi.isNotEmpty) {
          Kitap yeniKitap = Kitap(
            kitapAdi,
            DateTime.now(),
            kategori,
            kullaniciId,
          );
          dynamic kitapIdsi = await _uzakVeriTabani.createKitap(yeniKitap);
          debugPrint("Kitap Idsi: " + kitapIdsi.toString());
          _kitaplar = [];
          setState(() {});
        }
      }
    }
  }

  Future<void> _ilkKitaplariGetir() async {
    if (_kitaplar.length == 0) {
      String? kullaniciId = _auth.currentUser?.uid;

      if (kullaniciId != null) {
        List<dynamic> cekilenVeriler = await _uzakVeriTabani.readTumKitaplar(
          kullaniciId,
          _secilenKategori,
          null,
          10,
        );
        _kitaplar = cekilenVeriler[0];
        _sonKitapDokumani = cekilenVeriler[1];
        _kitapListesiniYazdir("İlk Kitaplar getirildi");
      }
    }
  }

  Future<void> _sonrakiKitaplariGetir() async {
    String? kullaniciId = _auth.currentUser?.uid;

    if (kullaniciId != null) {
      List<dynamic> cekilenVeriler = await _uzakVeriTabani.readTumKitaplar(
        kullaniciId,
        _secilenKategori,
        _sonKitapDokumani,
        10,
      );
      List<Kitap> sonrakiKitaplar = cekilenVeriler[0];
      _sonKitapDokumani = cekilenVeriler[1];
      _kitaplar.addAll(sonrakiKitaplar);
      _kitapListesiniYazdir("Sonraki Kitaplar getirildi");
      setState(() {});
    }
  }

  void _kitapGuncelle(BuildContext context, int index) async {
    Kitap kitap = _kitaplar[index];

    List<dynamic> sonuc = await _pencereAc(context, "Kitap Güncelle",
            mevcutIsim: kitap.isim, mevcutKategori: kitap.kategori) ??
        [];

    if (sonuc.isNotEmpty) {
      String yeniKitapAdi = sonuc[0];
      int yeniKategori = sonuc[1];

      if (yeniKitapAdi != kitap.isim || yeniKategori != kitap.kategori) {
        if (yeniKitapAdi.isNotEmpty) {
          kitap.isim = yeniKitapAdi;
        }
        kitap.kategori = yeniKategori;
        int guncellenenSatirSayisi = await _uzakVeriTabani.updateKitap(kitap);
        if (guncellenenSatirSayisi > 0) {
          setState(() {});
        }
      }
    }
  }

  void _kitapSil(int index) async {
    Kitap kitap = _kitaplar[index];
    int silinenSatirSayisi = await _uzakVeriTabani.deleteKitap(kitap);
    if (silinenSatirSayisi > 0) {
      _kitaplar = [];
      setState(() {});
    }
  }

  void _seciliKitaplariSil() async {
    int silinenSatirSayisi =
        await _uzakVeriTabani.deleteKitaplar(_secilenKitapIdleri);
    if (silinenSatirSayisi > 0) {
      _kitaplar = [];
      setState(() {});
    }
  }

  Future<List<dynamic>?> _pencereAc(BuildContext context, String baslik,
      {String mevcutIsim = "", int mevcutKategori = 0}) {
    TextEditingController isimController =
        TextEditingController(text: mevcutIsim);

    return showDialog<List<dynamic>>(
      context: context,
      builder: (context) {
        int kategori = mevcutKategori;
        return AlertDialog(
          title: Text(baslik),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: isimController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Kategori:"),
                      DropdownButton(
                        value: kategori,
                        onChanged: (int? yeniSecilenKategori) {
                          if (yeniSecilenKategori != null) {
                            setState(() {
                              kategori = yeniSecilenKategori;
                            });
                          }
                        },
                        items: Sabitler.kategoriler.keys
                            .map<DropdownMenuItem<int>>(
                          (kategoriId) {
                            return DropdownMenuItem<int>(
                              value: kategoriId,
                              child:
                                  Text(Sabitler.kategoriler[kategoriId] ?? ""),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.pop(context, []);
              },
            ),
            TextButton(
              child: Text("Onayla"),
              onPressed: () {
                Navigator.pop(context, [isimController.text.trim(), kategori]);
              },
            ),
          ],
        );
      },
    );
  }

  void _kitapListesiniYazdir(String ilkMesaj) {
    String kitapIsimleri = "";
    for (Kitap k in _kitaplar) {
      kitapIsimleri += "${k.isim}, ";
    }
    debugPrint("$ilkMesaj \n $kitapIsimleri");
  }

  _bolumlerSayfasiniAc(BuildContext context, int index) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return BolumlerSayfasi(_kitaplar[index]);
      },
    );
    Navigator.push(context, sayfaYolu);
  }

  void _cikisYap(BuildContext context) async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    _girisSayfasiniAc(context);
  }

  void _girisSayfasiniAc(BuildContext context) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return GirisSayfasi();
      },
    );
    Navigator.pushReplacement(context, sayfaYolu);
  }

  void _resimEkle(BuildContext context, int index) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? secilenDosya = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (secilenDosya != null) {
      File file = File(secilenDosya.path);

      Kitap kitap = _kitaplar[index];
      String dosyaIsmi = kitap.id;
      TaskSnapshot yukleme =
          await _storage.ref("kitaplar/$dosyaIsmi.jpg").putFile(file);
      String dosyaBaglantisi = await yukleme.ref.getDownloadURL();

      kitap.resim = dosyaBaglantisi;
      await _uzakVeriTabani.updateKitap(kitap);
    }
  }
}
