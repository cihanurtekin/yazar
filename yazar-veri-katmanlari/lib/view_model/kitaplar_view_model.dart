import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yazar/main.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/repository/depolama_repository.dart';
import 'package:yazar/repository/kimlik_dogrulama_repository.dart';
import 'package:yazar/repository/veri_tabani_repository.dart';
import 'package:yazar/sabitler.dart';
import 'package:yazar/view/bolumler_sayfasi.dart';
import 'package:yazar/view/giris_sayfasi.dart';
import 'package:yazar/view_model/bolumler_view_model.dart';
import 'package:yazar/view_model/giris_view_model.dart';

class KitaplarViewModel with ChangeNotifier {
  final VeriTabaniRepository _veriTabaniRepository =
      locator<VeriTabaniRepository>();
  final KimlikDogrulamaRepository _kimlikDogrulamaRepository =
      locator<KimlikDogrulamaRepository>();
  final DepolamaRepository _depolamaRepository = locator<DepolamaRepository>();

  List<Kitap> kitaplar = [];
  dynamic _sonKitap;

  List<int> tumKategoriler = [-1];
  int _secilenKategori = -1;

  int get secilenKategori => _secilenKategori;

  set secilenKategori(int value) {
    _secilenKategori = value;
  }

  List<dynamic> _secilenKitapIdleri = [];

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
    dynamic kullaniciId =
        await _kimlikDogrulamaRepository.kullaniciIdsiniGetir();

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
          dynamic kitapIdsi = await _veriTabaniRepository.createKitap(
            yeniKitap,
          );
          debugPrint("Kitap Idsi: " + kitapIdsi.toString());
          kitaplar = [];
          _sonKitap = null;
          _kitaplariGetir();
        }
      }
    }
  }

  Future<void> _kitaplariGetir() async {
    dynamic kullaniciId =
        await _kimlikDogrulamaRepository.kullaniciIdsiniGetir();

    if (kullaniciId != null) {
      List<dynamic> cekilenVeriler =
          await _veriTabaniRepository.readTumKitaplar(
        kullaniciId,
        _secilenKategori,
        _sonKitap,
        10,
      );
      List<Kitap> yeniKitaplar = cekilenVeriler[0];
      kitaplar.addAll(yeniKitaplar);
      _sonKitap = cekilenVeriler[1];
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
        int guncellenenSatirSayisi = await _veriTabaniRepository.updateKitap(
          kitap,
        );
      }
    }
  }

  void kitapSil(int index) async {
    Kitap kitap = kitaplar[index];
    int silinenSatirSayisi = await _veriTabaniRepository.deleteKitap(kitap);
    if (silinenSatirSayisi > 0) {
      kitaplar.removeAt(index);
      notifyListeners();
    }
  }

  void seciliKitaplariSil() async {
    int silinenSatirSayisi = await _veriTabaniRepository.deleteKitaplar(
      _secilenKitapIdleri,
    );
    if (silinenSatirSayisi > 0) {
      kitaplar.removeWhere((k) => _secilenKitapIdleri.contains(k.id));
      notifyListeners();
    }
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
      String dosyaBaglantisi = await _depolamaRepository.dosyaYukle(
        "kitaplar/$dosyaIsmi.jpg",
        file,
      );

      kitap.resim = dosyaBaglantisi;
      await _veriTabaniRepository.updateKitap(kitap);
    }
  }

  void cikisYap(BuildContext context) async {
    await _kimlikDogrulamaRepository.cikisYap();
    _girisSayfasiniAc(context);
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

  void kitapSecimiDegisti(int index, bool? yeniDeger) {
    if (yeniDeger != null) {
      dynamic kitapId = kitaplar[index].id;
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
    _sonKitap = null;
    if (yeniSecilenKategori != null) {
      secilenKategori = yeniSecilenKategori;
      _kitaplariGetir();
    }
  }
}
