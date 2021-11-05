import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:yazar/service/base/kimlik_dogrulama_service.dart';

class FirebaseKimlikDogrulamaService implements KimlikDogrulamaService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future kullaniciIdsiniGetir() async {
    return _auth.currentUser?.uid;
  }

  @override
  Future epostaVeSifreIleGiris(String eposta, String sifre) async {
    try {
      UserCredential kullaniciKimligi = await _auth.signInWithEmailAndPassword(
        email: eposta,
        password: sifre,
      );

      User? kullanici = kullaniciKimligi.user;
      return kullanici?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("Kullanıcı bulunamadı.");
      } else if (e.code == "wrong-password") {
        print("Yanlış şifre girdiniz.");
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future epostaVeSifreIleKayit(
    String adSoyad,
    String eposta,
    String sifre,
  ) async {
    try {
      UserCredential kullaniciKimligi =
          await _auth.createUserWithEmailAndPassword(
        email: eposta,
        password: sifre,
      );

      User? kullanici = kullaniciKimligi.user;
      await kullanici?.updateDisplayName(adSoyad);
      await kullanici?.sendEmailVerification();
      return kullanici?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        print("Parola çok zayıf.");
      } else if (e.code == "email-already-in-use") {
        print("Bu e-posta ile daha önce hesap oluşturulmuş.");
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future googleIleGiris() async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ["email"]);

    GoogleSignInAccount? googleKullanici = await googleSignIn.signIn();

    if (googleKullanici != null) {
      GoogleSignInAuthentication googleKimlik =
          await googleKullanici.authentication;

      AuthCredential dogrulamaKimligi = GoogleAuthProvider.credential(
        accessToken: googleKimlik.accessToken,
        idToken: googleKimlik.idToken,
      );
      UserCredential kullaniciKimligi = await _auth.signInWithCredential(
        dogrulamaKimligi,
      );

      User? kullanici = kullaniciKimligi.user;
      return kullanici?.uid;
    }
    return null;
  }

  @override
  Future appleIleGiris() async {
    AuthorizationCredentialAppleID appleKimlik =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
      ],
    );

    OAuthProvider oAuthProvider = OAuthProvider("apple.com");

    AuthCredential dogrulamaKimligi = oAuthProvider.credential(
      accessToken: appleKimlik.authorizationCode,
      idToken: appleKimlik.identityToken,
    );
    UserCredential kullaniciKimligi = await _auth.signInWithCredential(
      dogrulamaKimligi,
    );

    User? kullanici = kullaniciKimligi.user;
    return kullanici?.uid;
  }

  @override
  Future<void> telefonDogrulamaKoduGonder(
    String telefonNumarasi, {
    Function(dynamic kullaniciId)? otomatikDogrulama,
    Function(String hata)? dogrulamaBasarisiz,
    Function(dynamic dogrulamaIdsi)? dogrulamaKoduGonderildi,
    Function()? kodZamanAsimi,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: telefonNumarasi,
      verificationCompleted: (
        PhoneAuthCredential dogrulamaKimligi,
      ) async {
        UserCredential kullaniciKimligi = await _auth.signInWithCredential(
          dogrulamaKimligi,
        );

        User? kullanici = kullaniciKimligi.user;
        otomatikDogrulama?.call(kullanici?.uid);
      },
      verificationFailed: (FirebaseAuthException e) {
        dogrulamaBasarisiz?.call(e.code);
      },
      codeSent: (String verificationId, int? resendToken) {
        dogrulamaKoduGonderildi?.call(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        kodZamanAsimi?.call();
      },
    );
  }

  @override
  Future telefonDogrulamaKodunuOnayla(
    String dogrulamaIdsi,
    String dogrulamaKodu,
  ) async {
    try {
      PhoneAuthCredential dogrulamaKimligi = PhoneAuthProvider.credential(
        verificationId: dogrulamaIdsi,
        smsCode: dogrulamaKodu,
      );

      UserCredential kullaniciKimligi = await _auth.signInWithCredential(
        dogrulamaKimligi,
      );

      User? kullanici = kullaniciKimligi.user;
      return kullanici?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-verification-code") {
        print("Doğrulama kodu geçersiz.");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<void> sifreSifirla(String eposta) async {
    await _auth.sendPasswordResetEmail(email: eposta);
  }

  @override
  Future<void> cikisYap() async {
    await _auth.signOut();
  }
}
