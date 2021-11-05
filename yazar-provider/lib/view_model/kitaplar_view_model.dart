import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/sabitler.dart';
import 'package:yazar/veri_tabani/uzak_veri_tabani.dart';
import 'package:yazar/veri_tabani/yerel_veri_tabani.dart';
import 'package:yazar/view/bolumler_sayfasi.dart';
import 'package:yazar/view/giris_sayfasi.dart';
import 'package:yazar/view_model/bolumler_view_model.dart';
import 'package:yazar/view_model/giris_view_model.dart';

class KitaplarViewModel with ChangeNotifier {
  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();
  UzakVeriTabani _uzakVeriTabani = UzakVeriTabani();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  List<Kitap> kitaplar = [];
  DocumentSnapshot<Map<String, dynamic>>? _sonKitapDokumani;

  List<int> tumKategoriler = [-1];
  int _secilenKategori = -1;

  int get secilenKategori => _secilenKategori;

  set secilenKategori(int value) {
    _secilenKategori = value;
  }

  List<String> _secilenKitapIdleri = [];

  ScrollController scrollController = ScrollController();

  KitaplarViewModel() {
    tumKategoriler.addAll(Sabitler.kategoriler.keys);
    scrollController.addListener(_kaydirmaKontrol);
    _kitaplariGetir();
  }

  void _kaydirmaKontrol() {
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      _kitaplariGetir();
    }
  }

  void kitapEkle(BuildContext context) async {
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
          kitaplar = [];
          _sonKitapDokumani = null;
          _kitaplariGetir();
        }
      }
    }
  }

  Future<void> _kitaplariGetir() async {
    String? kullaniciId = _auth.currentUser?.uid;

    if (kullaniciId != null) {
      List<dynamic> cekilenVeriler = await _uzakVeriTabani.readTumKitaplar(
        kullaniciId,
        _secilenKategori,
        _sonKitapDokumani,
        10,
      );
      List<Kitap> yeniKitaplar = cekilenVeriler[0];
      kitaplar.addAll(yeniKitaplar);
      _sonKitapDokumani = cekilenVeriler[1];
      _kitapListesiniYazdir("Kitaplar getirildi");
      notifyListeners();
    }
  }

  void kitapGuncelle(BuildContext context, int index) async {
    Kitap kitap = kitaplar[index];

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
      }
    }
  }

  void kitapSil(int index) async {
    Kitap kitap = kitaplar[index];
    int silinenSatirSayisi = await _uzakVeriTabani.deleteKitap(kitap);
    if (silinenSatirSayisi > 0) {
      kitaplar.removeAt(index);
      notifyListeners();
    }
  }

  void seciliKitaplariSil() async {
    int silinenSatirSayisi =
        await _uzakVeriTabani.deleteKitaplar(_secilenKitapIdleri);
    if (silinenSatirSayisi > 0) {
      kitaplar.removeWhere((k) => _secilenKitapIdleri.contains(k.id));
      notifyListeners();
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
                              child: Text(
                                Sabitler.kategoriler[kategoriId] ?? "",
                              ),
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
                Navigator.pop(
                  context,
                  [isimController.text.trim(), kategori],
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _kitapListesiniYazdir(String ilkMesaj) {
    String kitapIsimleri = "";
    for (Kitap k in kitaplar) {
      kitapIsimleri += "${k.isim}, ";
    }
    debugPrint("$ilkMesaj \n $kitapIsimleri");
  }

  bolumlerSayfasiniAc(BuildContext context, int index) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => BolumlerViewModel(kitaplar[index]),
          child: BolumlerSayfasi(),
        );
      },
    );
    Navigator.push(context, sayfaYolu);
  }

  void cikisYap(BuildContext context) async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    _girisSayfasiniAc(context);
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

  void resimEkle(BuildContext context, int index) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? secilenDosya = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (secilenDosya != null) {
      File file = File(secilenDosya.path);

      Kitap kitap = kitaplar[index];
      String dosyaIsmi = kitap.id;
      TaskSnapshot yukleme =
          await _storage.ref("kitaplar/$dosyaIsmi.jpg").putFile(file);
      String dosyaBaglantisi = await yukleme.ref.getDownloadURL();

      kitap.resim = dosyaBaglantisi;
      await _uzakVeriTabani.updateKitap(kitap);
    }
  }

  void kitapSecimiDegisti(int index, bool? yeniDeger) {
    if (yeniDeger != null) {
      String? kitapId = kitaplar[index].id;
      if (kitapId != null) {
        if (yeniDeger) {
          _secilenKitapIdleri.add(kitapId);
        } else {
          _secilenKitapIdleri.remove(kitaplar[index].id);
        }
      }
    }
  }

  void kategoriSecimiDegisti(int? yeniSecilenKategori) {
    kitaplar = [];
    _sonKitapDokumani = null;
    if (yeniSecilenKategori != null) {
      secilenKategori = yeniSecilenKategori;
      _kitaplariGetir();
    }
  }
}
