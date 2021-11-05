import 'package:flutter/material.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/sabitler.dart';
import 'package:yazar/veri_tabani/yerel_veri_tabani.dart';
import 'package:yazar/view/bolumler_sayfasi.dart';

class KitaplarSayfasi extends StatefulWidget {
  @override
  State<KitaplarSayfasi> createState() => _KitaplarSayfasiState();
}

class _KitaplarSayfasiState extends State<KitaplarSayfasi> {
  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();

  List<Kitap> _kitaplar = [];

  List<int> _tumKategoriler = [-1];
  int _secilenKategori = -1;

  List<int> _secilenKitapIdleri = [];

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
      leading: CircleAvatar(
        child: Text(_kitaplar[index].id.toString()),
      ),
      title: Text(_kitaplar[index].isim),
      subtitle: Text(Sabitler.kategoriler[_kitaplar[index].kategori] ?? ""),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  int? kitapId = _kitaplar[index].id;
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
    List<dynamic> sonuc =
        await _pencereAc(context, "Kitap Adını Giriniz") ?? [];

    if (sonuc.isNotEmpty) {
      String kitapAdi = sonuc[0];
      int kategori = sonuc[1];

      if (kitapAdi.isNotEmpty) {
        Kitap yeniKitap = Kitap(kitapAdi, DateTime.now(), kategori);
        int kitapIdsi = await _yerelVeriTabani.createKitap(yeniKitap);
        debugPrint("Kitap Idsi: " + kitapIdsi.toString());
        _kitaplar = [];
        setState(() {});
      }
    }
  }

  Future<void> _ilkKitaplariGetir() async {
    if (_kitaplar.length == 0) {
      _kitaplar = await _yerelVeriTabani.readTumKitaplar(
        _secilenKategori,
        0,
        10,
      );
      _kitapListesiniYazdir("İlk Kitaplar getirildi");
    }
  }

  Future<void> _sonrakiKitaplariGetir() async {
    int? sonKitapId = _kitaplar.last.id;

    if (sonKitapId != null) {
      List<Kitap> sonrakiKitaplar = await _yerelVeriTabani.readTumKitaplar(
        _secilenKategori,
        sonKitapId,
        10,
      );
      _kitaplar.addAll(sonrakiKitaplar);
      _kitapListesiniYazdir("Sonraki Kitaplar getirildi");
      setState(() {});
    }
  }

  void _kitapListesiniYazdir(String ilkMesaj) {
    String kitapIsimleri = "";
    for (Kitap k in _kitaplar) {
      kitapIsimleri += "${k.isim}, ";
    }
    debugPrint("$ilkMesaj \n $kitapIsimleri");
  }

  void _kitapGuncelle(BuildContext context, int index) async {
    Kitap kitap = _kitaplar[index];

    List<dynamic> sonuc = await _pencereAc(context, "Kitap Güncelle",
        mevcutIsim: kitap.isim, mevcutKategori: kitap.kategori) ?? [];

    if (sonuc.isNotEmpty) {
      String yeniKitapAdi = sonuc[0];
      int yeniKategori = sonuc[1];

      if (yeniKitapAdi != kitap.isim || yeniKategori != kitap.kategori) {
        if (yeniKitapAdi.isNotEmpty) {
          kitap.isim = yeniKitapAdi;
        }
        kitap.kategori = yeniKategori;
        int guncellenenSatirSayisi = await _yerelVeriTabani.updateKitap(kitap);
        if (guncellenenSatirSayisi > 0) {
          setState(() {});
        }
      }
    }
  }

  void _kitapSil(int index) async {
    Kitap kitap = _kitaplar[index];
    int silinenSatirSayisi = await _yerelVeriTabani.deleteKitap(kitap);
    if (silinenSatirSayisi > 0) {
      _kitaplar = [];
      setState(() {});
    }
  }

  void _seciliKitaplariSil() async {
    int silinenSatirSayisi =
        await _yerelVeriTabani.deleteKitaplar(_secilenKitapIdleri);
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

  _bolumlerSayfasiniAc(BuildContext context, int index) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return BolumlerSayfasi(_kitaplar[index]);
      },
    );
    Navigator.push(context, sayfaYolu);
  }
}
