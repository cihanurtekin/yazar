import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/service/base/veri_tabani_service.dart';

class FirestoreVeriTabaniService implements VeriTabaniService {
  final FirebaseFirestore _veriTabani = FirebaseFirestore.instance;

  final String _kitaplarKoleksiyonAdi = "kitaplar";
  final String _bolumlerKoleksiyonAdi = "bolumler";

  @override
  Future createKitap(Kitap kitap) async {
    Map<String, dynamic> kitapMap = kitap.mapeDonustur();
    kitapMap["olusturulmaTarihi"] = FieldValue.serverTimestamp();

    await _veriTabani.collection(_kitaplarKoleksiyonAdi).doc().set(kitapMap);
    return "";
  }

  @override
  Future<List> readTumKitaplar(
    kullaniciId,
    int kategoriId,
    sonKitap,
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

    if (sonKitap != null) {
      sorgu = sorgu.startAfterDocument(sonKitap);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await sorgu.get();

    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> dokuman in snapshot.docs) {
        Map<String, dynamic>? kitapMap = dokuman.data();
        kitapMap?["id"] = dokuman.id;
        kitapMap?["olusturulmaTarihi"] =
            (kitapMap["olusturulmaTarihi"] as Timestamp).toDate();

        if (kitapMap != null) {
          Kitap kitap = Kitap.maptenOlustur(kitapMap);
          kitaplar.add(kitap);
        }
      }
      sonKitap = snapshot.docs.last;
    }
    return [kitaplar, sonKitap];
  }

  @override
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

  @override
  Future<int> deleteKitap(Kitap kitap) async {
    await _veriTabani.collection(_kitaplarKoleksiyonAdi).doc(kitap.id).delete();
    return 1;
  }

  @override
  Future<int> deleteKitaplar(List kitapIdleri) async {
    WriteBatch batch = _veriTabani.batch();
    for (String kitapId in kitapIdleri) {
      batch.delete(
        _veriTabani.collection(_kitaplarKoleksiyonAdi).doc(kitapId),
      );
    }
    await batch.commit();
    return kitapIdleri.length;
  }

  @override
  Future createBolum(Bolum bolum) async {
    Map<String, dynamic> bolumMap = bolum.mapeDonustur();
    bolumMap["olusturulmaTarihi"] = FieldValue.serverTimestamp();

    await _veriTabani
        .collection(_kitaplarKoleksiyonAdi)
        .doc(bolum.kitapId)
        .collection(_bolumlerKoleksiyonAdi)
        .doc()
        .set(bolumMap);
    return "";
  }

  @override
  Future<List<Bolum>> readTumBolumler(kullaniciId, kitapId) async {
    List<Bolum> bolumler = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await _veriTabani
        .collection(_kitaplarKoleksiyonAdi)
        .doc(kitapId)
        .collection(_bolumlerKoleksiyonAdi)
        .where("kullaniciId", isEqualTo: kullaniciId)
        .where("kitapId", isEqualTo: kitapId)
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

  @override
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

  @override
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
