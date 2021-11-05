abstract class KimlikDogrulamaBase {
  Future<dynamic> kullaniciIdsiniGetir();

  Future<dynamic> epostaVeSifreIleGiris(
    String eposta,
    String sifre,
  );

  Future<dynamic> epostaVeSifreIleKayit(
    String adSoyad,
    String eposta,
    String sifre,
  );

  Future<dynamic> googleIleGiris();

  Future<dynamic> appleIleGiris();

  Future<void> telefonDogrulamaKoduGonder(
    String telefonNumarasi, {
    Function(dynamic kullaniciId)? otomatikDogrulama,
    Function(String hata)? dogrulamaBasarisiz,
    Function(dynamic dogrulamaIdsi)? dogrulamaKoduGonderildi,
    Function()? kodZamanAsimi,
  });

  Future<dynamic> telefonDogrulamaKodunuOnayla(
    String dogrulamaIdsi,
    String dogrulamaKodu,
  );

  Future<void> sifreSifirla(String eposta);

  Future<void> cikisYap();
}
