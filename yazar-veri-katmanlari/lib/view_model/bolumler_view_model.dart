import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/main.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/repository/veri_tabani_repository.dart';
import 'package:yazar/view/bolum_detay_sayfasi.dart';
import 'package:yazar/view_model/bolum_detay_view_model.dart';

class BolumlerViewModel with ChangeNotifier {
  final VeriTabaniRepository _veriTabaniRepository =
      locator<VeriTabaniRepository>();

  List<Bolum> bolumler = [];

  final Kitap kitap;

  BolumlerViewModel(this.kitap) {
    _tumBolumleriGetir();
  }

  void bolumEkle(BuildContext context) async {
    String bolumBasligi =
        await _pencereAc(context, "Bölüm Adını Giriniz") ?? "";
    dynamic kitapId = kitap.id;
    if (bolumBasligi.isNotEmpty && kitapId != null) {
      Bolum yeniBolum = Bolum(kitapId, bolumBasligi, kitap.kullaniciId);
      dynamic bolumIdsi = await _veriTabaniRepository.createBolum(yeniBolum);
      debugPrint("Bolum Idsi: " + bolumIdsi.toString());
      _tumBolumleriGetir();
    }
  }

  Future<void> _tumBolumleriGetir() async {
    dynamic kullaniciId = kitap.kullaniciId;
    dynamic kitapId = kitap.id;
    if (kullaniciId != null && kitapId != null) {
      bolumler = await _veriTabaniRepository.readTumBolumler(
        kullaniciId,
        kitapId,
      );
    }
    notifyListeners();
  }

  void bolumGuncelle(BuildContext context, int index) async {
    String yeniBolumBasligi = await _pencereAc(context, "Bölüm Güncelle") ?? "";
    if (yeniBolumBasligi.isNotEmpty) {
      Bolum bolum = bolumler[index];
      bolum.baslik = yeniBolumBasligi;
      int guncellenenSatirSayisi = await _veriTabaniRepository.updateBolum(
        bolum,
      );
    }
  }

  void bolumSil(int index) async {
    Bolum bolum = bolumler[index];
    int silinenSatirSayisi = await _veriTabaniRepository.deleteBolum(bolum);
    if (silinenSatirSayisi > 0) {
      bolumler.removeAt(index);
      notifyListeners();
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

  void bolumDetaySayfasiniAc(BuildContext context, int index) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => BolumDetayViewModel(
            bolumler[index],
          ),
          child: BolumDetaySayfasi(),
        );
      },
    );
    Navigator.push(context, sayfaYolu);
  }
}
