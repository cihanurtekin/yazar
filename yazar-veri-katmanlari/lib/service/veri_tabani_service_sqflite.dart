import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/service/base/veri_tabani_service.dart';

class SqfliteVeriTabaniService implements VeriTabaniService {
  Database? _veriTabani;

  final String _kitaplarTabloAdi = "kitaplar";
  final String _idKitaplar = "id";
  final String _isimKitaplar = "isim";
  final String _olusturulmaTarihiKitaplar = "olusturulmaTarihi";
  final String _kategoriKitaplar = "kategori";

  final String _bolumlerTabloAdi = "bolumler";
  final String _idBolumler = "id";
  final String _kitapIdBolumler = "kitapId";
  final String _baslikBolumler = "baslik";
  final String _icerikBolumler = "icerik";
  final String _olusturulmaTarihiBolumler = "olusturulmaTarihi";

  Future<Database?> _veriTabaniniGetir() async {
    if (_veriTabani == null) {
      String dosyaYolu = await getDatabasesPath();
      String veriTabaniYolu = join(dosyaYolu, "yazar.db");
      _veriTabani = await openDatabase(
        veriTabaniYolu,
        version: 3,
        onCreate: _tabloOlustur,
        onUpgrade: _tabloGuncelle,
      );
    }
    return _veriTabani;
  }

  Future<void> _tabloOlustur(Database db, int versiyon) async {
    await db.execute('''
      CREATE TABLE $_kitaplarTabloAdi (
      $_idKitaplar INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT,
      $_isimKitaplar TEXT NOT NULL,
      $_olusturulmaTarihiKitaplar INTEGER,
      $_kategoriKitaplar INTEGER DEFAULT 0);
    ''');
    await db.execute('''
      CREATE TABLE $_bolumlerTabloAdi (
      $_idBolumler INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT,
      $_kitapIdBolumler INTEGER NOT NULL,
      $_baslikBolumler TEXT NOT NULL,
      $_icerikBolumler TEXT,
      $_olusturulmaTarihiBolumler TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY("$_kitapIdBolumler") REFERENCES "$_kitaplarTabloAdi"("$_idKitaplar") ON DELETE CASCADE ON UPDATE CASCADE);
    ''');
  }

  Future<void> _tabloGuncelle(
      Database db, int eskiVersiyon, int yeniVersiyon) async {
    List<String> guncellemeKomutlari = [
      "ALTER TABLE $_kitaplarTabloAdi ADD COLUMN $_kategoriKitaplar INTEGER DEFAULT 0",
      "ALTER TABLE $_kitaplarTabloAdi ADD COLUMN test INTEGER DEFAULT 0",
    ];
    for (int i = eskiVersiyon - 1; i < yeniVersiyon - 1; i++) {
      await db.execute(guncellemeKomutlari[i]);
    }
  }

  @override
  Future createKitap(Kitap kitap) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      Map<String, dynamic> kitapMap = kitap.mapeDonustur();
      kitapMap["olusturulmaTarihi"] =
          kitap.olusturulmaTarihi.millisecondsSinceEpoch;
      kitapMap.remove("kullaniciId");
      kitapMap.remove("resim");

      return await db.insert(_kitaplarTabloAdi, kitapMap);
    } else {
      return -1;
    }
  }

  @override
  Future<List> readTumKitaplar(
    kullaniciId,
    int kategoriId,
    sonKitap,
    int cekilecekVeriSayisi,
  ) async {
    Database? db = await _veriTabaniniGetir();
    List<Kitap> kitaplar = [];

    if (db != null) {
      String filtre = "$_idKitaplar > ?";

      List<dynamic> filtreArgumanlari = [];
      filtreArgumanlari.add(sonKitap ?? 0);

      if (kategoriId >= 0) {
        filtre += " and $_kategoriKitaplar = ?";
        filtreArgumanlari.add(kategoriId);
      }

      List<Map<String, dynamic>> kitaplarMap = await db.query(
        _kitaplarTabloAdi,
        where: filtre,
        whereArgs: filtreArgumanlari,
        limit: cekilecekVeriSayisi,
      );

      for (Map<String, dynamic> m in kitaplarMap) {
        Map<String, dynamic> kitapMap = Map.of(m);
        kitapMap["olusturulmaTarihi"] = DateTime.fromMillisecondsSinceEpoch(
          kitapMap["olusturulmaTarihi"],
        );
        Kitap k = Kitap.maptenOlustur(kitapMap);
        kitaplar.add(k);
      }
      if (kitaplar.isNotEmpty) {
        sonKitap = kitaplar.last.id;
      }
    }
    return [kitaplar, sonKitap];
  }

  @override
  Future<int> updateKitap(Kitap kitap) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      Map<String, dynamic> kitapMap = kitap.mapeDonustur();
      kitapMap["olusturulmaTarihi"] =
          kitap.olusturulmaTarihi.millisecondsSinceEpoch;
      kitapMap.remove("kullaniciId");
      kitapMap.remove("resim");

      return await db.update(
        _kitaplarTabloAdi,
        kitapMap,
        where: "$_idKitaplar = ?",
        whereArgs: [kitap.id],
      );
    } else {
      return 0;
    }
  }

  @override
  Future<int> deleteKitap(Kitap kitap) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      return await db.delete(
        _kitaplarTabloAdi,
        where: "$_idKitaplar = ?",
        whereArgs: [kitap.id],
      );
    } else {
      return 0;
    }
  }

  @override
  Future<int> deleteKitaplar(List kitapIdleri) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null && kitapIdleri.length > 0) {
      String filtre = "$_idKitaplar in (";

      for (int i = 0; i < kitapIdleri.length; i++) {
        if (i != kitapIdleri.length - 1) {
          filtre += "?,";
        } else {
          filtre += "?)";
        }
      }

      return await db.delete(
        _kitaplarTabloAdi,
        where: filtre,
        whereArgs: kitapIdleri,
      );
    } else {
      return 0;
    }
  }

  @override
  Future createBolum(Bolum bolum) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      Map<String, dynamic> bolumMap = bolum.mapeDonustur();
      bolumMap["olusturulmaTarihi"] = DateTime.now().millisecondsSinceEpoch;
      bolumMap.remove("kullaniciId");

      return await db.insert(_bolumlerTabloAdi, bolumMap);
    } else {
      return -1;
    }
  }

  @override
  Future<List<Bolum>> readTumBolumler(kullaniciId, kitapId) async {
    Database? db = await _veriTabaniniGetir();
    List<Bolum> bolumler = [];

    if (db != null) {
      List<Map<String, dynamic>> bolumlerMap = await db.query(
        _bolumlerTabloAdi,
        where: "$_kitapIdBolumler = ?",
        whereArgs: [kitapId],
      );

      for (Map<String, dynamic> m in bolumlerMap) {
        Bolum b = Bolum.maptenOlustur(m);
        bolumler.add(b);
      }
    }
    return bolumler;
  }

  @override
  Future<int> updateBolum(Bolum bolum) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      Map<String, dynamic> bolumMap = bolum.mapeDonustur();
      bolumMap.remove("olusturulmaTarihi");
      bolumMap.remove("kullaniciId");

      return await db.update(
        _bolumlerTabloAdi,
        bolumMap,
        where: "$_idBolumler = ?",
        whereArgs: [bolum.id],
      );
    } else {
      return 0;
    }
  }

  @override
  Future<int> deleteBolum(Bolum bolum) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      return await db.delete(
        _bolumlerTabloAdi,
        where: "$_idBolumler = ?",
        whereArgs: [bolum.id],
      );
    } else {
      return 0;
    }
  }
}
