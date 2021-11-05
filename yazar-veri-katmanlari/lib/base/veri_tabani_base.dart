import 'package:yazar/model/bolum.dart';
import 'package:yazar/model/kitap.dart';

abstract class VeriTabaniBase {
  Future<dynamic> createKitap(Kitap kitap);

  Future<List<dynamic>> readTumKitaplar(
    dynamic kullaniciId,
    int kategoriId,
    dynamic sonKitap,
    int cekilecekVeriSayisi,
  );

  Future<int> updateKitap(Kitap kitap);

  Future<int> deleteKitap(Kitap kitap);

  Future<int> deleteKitaplar(List<dynamic> kitapIdleri);

  Future<dynamic> createBolum(Bolum bolum);

  Future<List<Bolum>> readTumBolumler(
    dynamic kullaniciId,
    dynamic kitapId,
  );

  Future<int> updateBolum(Bolum bolum);

  Future<int> deleteBolum(Bolum bolum);
}
