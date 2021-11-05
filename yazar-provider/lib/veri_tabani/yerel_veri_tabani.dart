import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/model/kitap.dart';

class YerelVeriTabani {
  YerelVeriTabani._privateConstructor();

  static final YerelVeriTabani _nesne = YerelVeriTabani._privateConstructor();

  factory YerelVeriTabani() {
    return _nesne;
  }

  Database? _veriTabani;

  String _kitaplarTabloAdi = "kitaplar";
  String _idKitaplar = "id";
  String _isimKitaplar = "isim";
  String _olusturulmaTarihiKitaplar = "olusturulmaTarihi";
  String _kategoriKitaplar = "kategori";

  String _bolumlerTabloAdi = "bolumler";
  String _idBolumler = "id";
  String _kitapIdBolumler = "kitapId";
  String _baslikBolumler = "baslik";
  String _icerikBolumler = "icerik";
  String _olusturulmaTarihiBolumler = "olusturulmaTarihi";

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

  Future<void> _tabloGuncelle(Database db, int eskiVersiyon, int yeniVersiyon) async {
    List<String> guncellemeKomutlari = [
      "ALTER TABLE $_kitaplarTabloAdi ADD COLUMN $_kategoriKitaplar INTEGER DEFAULT 0",
      "ALTER TABLE $_kitaplarTabloAdi ADD COLUMN test INTEGER DEFAULT 0",
    ];
    for (int i = eskiVersiyon - 1; i < yeniVersiyon - 1; i++) {
      await db.execute(guncellemeKomutlari[i]);
    }
  }

  Future<int> createKitap(Kitap kitap) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      return await db.insert(_kitaplarTabloAdi, kitap.mapeDonustur());
    } else {
      return -1;
    }
  }

  Future<List<Kitap>> readTumKitaplar(
      int kategoriId,
      int sonKitapId,
      int cekilecekVeriSayisi,
      ) async {
    Database? db = await _veriTabaniniGetir();
    List<Kitap> kitaplar = [];

    if (db != null) {
      String filtre = "$_idKitaplar > ?";

      List<dynamic> filtreArgumanlari = [];
      filtreArgumanlari.add(sonKitapId);

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
        Kitap k = Kitap.maptenOlustur(m);
        kitaplar.add(k);
      }
    }
    return kitaplar;
  }

  Future<int> updateKitap(Kitap kitap) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      return await db.update(
        _kitaplarTabloAdi,
        kitap.mapeDonustur(),
        where: "$_idKitaplar = ?",
        whereArgs: [kitap.id],
      );
    } else {
      return 0;
    }
  }

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

  Future<int> deleteKitaplar(List<int> kitapIdleri) async {
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

  Future<int> createBolum(Bolum bolum) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      return await db.insert(_bolumlerTabloAdi, bolum.mapeDonustur());
    } else {
      return -1;
    }
  }

  Future<List<Bolum>> readTumBolumler(int kitapId) async {
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

  Future<int> updateBolum(Bolum bolum) async {
    Database? db = await _veriTabaniniGetir();
    if (db != null) {
      return await db.update(
        _bolumlerTabloAdi,
        bolum.mapeDonustur(),
        where: "$_idBolumler = ?",
        whereArgs: [bolum.id],
      );
    } else {
      return 0;
    }
  }

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
