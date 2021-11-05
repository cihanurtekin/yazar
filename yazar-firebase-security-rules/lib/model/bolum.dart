import 'package:cloud_firestore/cloud_firestore.dart';

class Bolum {
  dynamic id;
  dynamic kitapId;
  late String baslik;
  late String icerik;
  late String kullaniciId;

  Bolum(this.kitapId, this.baslik, this.kullaniciId) {
    icerik = "";
  }

  Map<String, dynamic> mapeDonustur() {
    return {
      "kitapId": this.kitapId,
      "baslik": this.baslik,
      "icerik": this.icerik,
      "olusturulmaTarihi": FieldValue.serverTimestamp(),
      "kullaniciId": this.kullaniciId,
    };
  }

  Bolum.maptenOlustur(Map<String, dynamic> map) {
    this.id = map["id"];
    this.kitapId = map["kitapId"];
    this.baslik = map["baslik"];
    this.icerik = map["icerik"];
    this.kullaniciId = map["kullaniciId"];
  }
}
