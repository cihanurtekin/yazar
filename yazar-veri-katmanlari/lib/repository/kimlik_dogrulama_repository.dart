import 'package:google_sign_in/google_sign_in.dart';
import 'package:yazar/base/kimlik_dogrulama_base.dart';
import 'package:yazar/main.dart';
import 'package:yazar/service/base/kimlik_dogrulama_service.dart';
import 'package:yazar/service/kimlik_dogrulama_service_firebase.dart';

class KimlikDogrulamaRepository implements KimlikDogrulamaBase {
  final KimlikDogrulamaService _service =
      locator<FirebaseKimlikDogrulamaService>();

  @override
  Future kullaniciIdsiniGetir() async {
    return await _service.kullaniciIdsiniGetir();
  }

  @override
  Future epostaVeSifreIleGiris(String eposta, String sifre) async {
    return await _service.epostaVeSifreIleGiris(eposta, sifre);
  }

  @override
  Future epostaVeSifreIleKayit(
    String adSoyad,
    String eposta,
    String sifre,
  ) async {
    return await _service.epostaVeSifreIleKayit(adSoyad, eposta, sifre);
  }

  @override
  Future googleIleGiris() async {
    return await _service.googleIleGiris();
  }

  @override
  Future appleIleGiris() async {
    return await _service.appleIleGiris();
  }

  @override
  Future<void> telefonDogrulamaKoduGonder(
    String telefonNumarasi, {
    Function(dynamic kullaniciId)? otomatikDogrulama,
    Function(String hata)? dogrulamaBasarisiz,
    Function(dynamic dogrulamaIdsi)? dogrulamaKoduGonderildi,
    Function()? kodZamanAsimi,
  }) async {
    return await _service.telefonDogrulamaKoduGonder(
      telefonNumarasi,
      otomatikDogrulama: otomatikDogrulama,
      dogrulamaBasarisiz: dogrulamaBasarisiz,
      dogrulamaKoduGonderildi: dogrulamaKoduGonderildi,
      kodZamanAsimi: kodZamanAsimi,
    );
  }

  @override
  Future telefonDogrulamaKodunuOnayla(
    String dogrulamaIdsi,
    String dogrulamaKodu,
  ) async {
    return await _service.telefonDogrulamaKodunuOnayla(
      dogrulamaIdsi,
      dogrulamaKodu,
    );
  }

  @override
  Future<void> sifreSifirla(String eposta) async {
    return await _service.sifreSifirla(eposta);
  }

  @override
  Future<void> cikisYap() async {
    await GoogleSignIn().signOut();
    return await _service.cikisYap();
  }
}
