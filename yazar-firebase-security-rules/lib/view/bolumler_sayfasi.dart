import 'package:flutter/material.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/veri_tabani/uzak_veri_tabani.dart';
import 'package:yazar/veri_tabani/yerel_veri_tabani.dart';
import 'package:yazar/view/bolum_detay_sayfasi.dart';

class BolumlerSayfasi extends StatefulWidget {
  final Kitap kitap;

  BolumlerSayfasi(this.kitap);

  @override
  _BolumlerSayfasiState createState() => _BolumlerSayfasiState();
}

class _BolumlerSayfasiState extends State<BolumlerSayfasi> {
  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();
  UzakVeriTabani _uzakVeriTabani = UzakVeriTabani();

  List<Bolum> _bolumler = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kitap.isim),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _bolumEkle(context);
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<void>(
      future: _tumBolumleriGetir(),
      builder: _buildListView,
    );
  }

  Widget _buildListView(BuildContext context, AsyncSnapshot<void> snapshot) {
    return ListView.builder(
      itemCount: _bolumler.length,
      itemBuilder: _buildListTile,
    );
  }

  Widget _buildListTile(BuildContext context, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(_bolumler[index].id.toString()),
      ),
      title: Text(_bolumler[index].baslik),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _bolumGuncelle(context, index);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _bolumSil(index);
            },
          ),
        ],
      ),
      onTap: () {
        _bolumDetaySayfasiniAc(context, index);
      },
    );
  }

  void _bolumEkle(BuildContext context) async {
    String bolumBasligi = await _pencereAc(context, "Bölüm Adını Giriniz") ?? "";
    dynamic kitapId = widget.kitap.id;
    if (bolumBasligi.isNotEmpty && kitapId != null) {
      Bolum yeniBolum = Bolum(kitapId, bolumBasligi, widget.kitap.kullaniciId);
      dynamic bolumIdsi = await _uzakVeriTabani.createBolum(yeniBolum);
      debugPrint("Bolum Idsi: " + bolumIdsi.toString());
      setState(() {});
    }
  }

  Future<void> _tumBolumleriGetir() async {
    dynamic kullaniciId = widget.kitap.kullaniciId;
    dynamic kitapId = widget.kitap.id;
    if (kullaniciId != null && kitapId != null) {
      _bolumler = await _uzakVeriTabani.readTumBolumler(
        kullaniciId,
        kitapId,
      );
    }
  }

  void _bolumGuncelle(BuildContext context, int index) async {
    String yeniBolumBasligi = await _pencereAc(context, "Bölüm Güncelle") ?? "";
    if (yeniBolumBasligi.isNotEmpty) {
      Bolum bolum = _bolumler[index];
      bolum.baslik = yeniBolumBasligi;
      int guncellenenSatirSayisi = await _uzakVeriTabani.updateBolum(bolum);
      if (guncellenenSatirSayisi > 0) {
        setState(() {});
      }
    }
  }

  void _bolumSil(int index) async {
    Bolum bolum = _bolumler[index];
    int silinenSatirSayisi = await _uzakVeriTabani.deleteBolum(bolum);
    if (silinenSatirSayisi > 0) {
      setState(() {});
    }
  }

  Future<String?> _pencereAc(BuildContext context, String baslik) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        String sonuc = "";
        return AlertDialog(
          title: Text(baslik),
          content: TextField(
            keyboardType: TextInputType.text,
            onChanged: (String inputText) {
              sonuc = inputText;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.pop(context, "");
              },
            ),
            TextButton(
              child: Text("Onayla"),
              onPressed: () {
                Navigator.pop(context, sonuc.trim());
              },
            ),
          ],
        );
      },
    );
  }

  _bolumDetaySayfasiniAc(BuildContext context, int index) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return BolumDetaySayfasi(_bolumler[index]);
      },
    );
    Navigator.push(context, sayfaYolu);
  }
}
