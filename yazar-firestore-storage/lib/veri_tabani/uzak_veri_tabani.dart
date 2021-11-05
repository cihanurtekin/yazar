import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/model/kitap.dart';

class UzakVeriTabani {
  UzakVeriTabani._privateConstructor();

  static final UzakVeriTabani _nesne = UzakVeriTabani._privateConstructor();

  factory UzakVeriTabani() {
    return _nesne;
  }

  FirebaseFirestore _veriTabani = FirebaseFirestore.instance;

  String _kitaplarKoleksiyonAdi = "kitaplar";
  String _bolumlerKoleksiyonAdi = "bolumler";

  Future<String> createKitap(Kitap kitap) async {
    await _veriTabani
        .collection(_kitaplarKoleksiyonAdi)
        .doc()
        .set(kitap.mapeDonustur());
    return "";
  }

  Future<List<dynamic>> readTumKitaplar(
    String kullaniciId,
    int kategoriId,
    DocumentSnapshot<Map<String, dynamic>>? sonKitapDokumani,
    int cekilecekVeriSayisi,
  ) async {
    List<Kitap> kitaplar = [];

    Query<Map<String, dynamic>> sorgu = _veriTabani
        .collection(_kitaplarKoleksiyonAdi)
        .where("kullaniciId", isEqualTo: kullaniciId);

    if (kategoriId != -1) {
      sorgu = sorgu.where("kategori", isEqualTo: kategoriId);
    } else {
      sorgu = sorgu.orderBy("kategori", descending: true);
    }

    sorgu = sorgu.orderBy("isim").limit(cekilecekVeriSayisi);

    if (sonKitapDokumani != null) {
      sorgu = sorgu.startAfterDocument(sonKitapDokumani);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await sorgu.get();

    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> dokuman in snapshot.docs) {
        Map<String, dynamic>? kitapMap = dokuman.data();
        kitapMap?["id"] = dokuman.id;
        if (kitapMap != null) {
          Kitap kitap = Kitap.maptenOlustur(kitapMap);
          kitaplar.add(kitap);
        }
      }
      sonKitapDokumani = snapshot.docs.last;
    }
    return [kitaplar, sonKitapDokumani];
  }

  Future<int> updateKitap(Kitap kitap) async {
    Map<String, dynamic> guncellenecekAlanlar = {
      "isim": kitap.isim,
      "kategori": kitap.kategori,
      "resim": kitap.resim,
    };

    await _veriTabani
        .collection(_kitaplarKoleksiyonAdi)
        .doc(kitap.id)
        .update(guncellenecekAlanlar);

    return 1;
  }

  Future<int> deleteKitap(Kitap kitap) async {
    await _veriTabani.collection(_kitaplarKoleksiyonAdi).doc(kitap.id).delete();
    return 1;
  }

  Future<int> deleteKitaplar(List<String> kitapIdleri) async {
    WriteBatch batch = _veriTabani.batch();
    for (String kitapId in kitapIdleri) {
      batch.delete(
        _veriTabani.collection(_kitaplarKoleksiyonAdi).doc(kitapId),
      );
    }
    await batch.commit();
    return kitapIdleri.length;
  }

  Future<String> createBolum(Bolum bolum) async {
    await _veriTabani
        .collection(_kitaplarKoleksiyonAdi)
        .doc(bolum.kitapId)
        .collection(_bolumlerKoleksiyonAdi)
        .doc()
        .set(bolum.mapeDonustur());
    return "";
  }

  Future<List<Bolum>> readTumBolumler(String kitapId) async {
    List<Bolum> bolumler = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await _veriTabani
        .collection(_kitaplarKoleksiyonAdi)
        .doc(kitapId)
        .collection(_bolumlerKoleksiyonAdi)
        .get();

    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> dokuman in snapshot.docs) {
        Map<String, dynamic>? bolumMap = dokuman.data();
        bolumMap?["id"] = dokuman.id;
        if (bolumMap != null) {
          Bolum bolum = Bolum.maptenOlustur(bolumMap);
          bolumler.add(bolum);
        }
      }
    }
    return bolumler;
  }

  Future<int> updateBolum(Bolum bolum) async {
    Map<String, dynamic> guncellenecekAlanlar = {
      "baslik": bolum.baslik,
      "icerik": bolum.icerik,
    };

    await _veriTabani
        .collection(_kitaplarKoleksiyonAdi)
        .doc(bolum.kitapId)
        .collection(_bolumlerKoleksiyonAdi)
        .doc(bolum.id)
        .update(guncellenecekAlanlar);

    return 1;
  }

  Future<int> deleteBolum(Bolum bolum) async {
    await _veriTabani
        .collection(_kitaplarKoleksiyonAdi)
        .doc(bolum.kitapId)
        .collection(_bolumlerKoleksiyonAdi)
        .doc(bolum.id)
        .delete();

    return 1;
  }
}
