class Kitap {
  int? id;
  late String isim;
  late DateTime olusturulmaTarihi;
  late int kategori;

  Kitap(this.isim, this.olusturulmaTarihi, this.kategori);

  Map<String, dynamic> mapeDonustur() {
    return {
      "id": this.id,
      "isim": this.isim,
      "olusturulmaTarihi": this.olusturulmaTarihi.millisecondsSinceEpoch,
      "kategori": this.kategori,
    };
  }

  Kitap.maptenOlustur(Map<String, dynamic> map) {
    this.id = map["id"];
    this.isim = map["isim"];
    this.olusturulmaTarihi = DateTime.fromMillisecondsSinceEpoch(map["olusturulmaTarihi"]);
    this.kategori = map["kategori"] ?? 0;
  }
}
