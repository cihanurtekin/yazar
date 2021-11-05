class Bolum {
  int? id;
  late int kitapId;
  late String baslik;
  late String icerik;

  Bolum(this.kitapId, this.baslik) {
    icerik = "";
  }

  Map<String, dynamic> mapeDonustur() {
    return {
      "id": this.id,
      "kitapId": this.kitapId,
      "baslik": this.baslik,
      "icerik": this.icerik,
    };
  }

  Bolum.maptenOlustur(Map<String, dynamic> map) {
    this.id = map["id"];
    this.kitapId = map["kitapId"];
    this.baslik = map["baslik"];
    this.icerik = map["icerik"];
  }
}