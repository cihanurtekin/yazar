import 'package:cloud_firestore/cloud_firestore.dart';

class Kitap {
  dynamic id;
  late String isim;
  late DateTime olusturulmaTarihi;
  late int kategori;
  late String kullaniciId;
  String? resim;

  Kitap(this.isim, this.olusturulmaTarihi, this.kategori, this.kullaniciId);

  Map<String, dynamic> mapeDonustur() {
    return {
      "isim": this.isim,
      "olusturulmaTarihi": FieldValue.serverTimestamp(),
      "kategori": this.kategori,
      "kullaniciId": this.kullaniciId,
      "resim": this.resim,
    };
  }

  Kitap.maptenOlustur(Map<String, dynamic> map) {
    this.id = map["id"];
    this.isim = map["isim"];
    this.olusturulmaTarihi = (map["olusturulmaTarihi"] as Timestamp).toDate();
    this.kategori = map["kategori"] ?? 0;
    this.kullaniciId = map["kullaniciId"];
    this.resim = map["resim"];
  }
}
