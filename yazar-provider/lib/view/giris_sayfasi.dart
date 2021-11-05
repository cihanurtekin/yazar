import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/view_model/giris_view_model.dart';

class GirisSayfasi extends StatelessWidget {
  TextEditingController _epostaController = TextEditingController();
  TextEditingController _sifreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giriş Sayfası"),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 32, left: 16, right: 16),
      child: Column(
        children: [
          TextField(
            controller: _epostaController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "E-posta",
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _sifreController,
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Şifre",
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Giriş Yap"),
              onPressed: () {
                GirisViewModel viewModel = Provider.of<GirisViewModel>(
                  context,
                  listen: false,
                );
                viewModel.epostaVeSifreIleGiris(
                  context,
                  _epostaController.text.trim(),
                  _sifreController.text.trim(),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Hesabınız yok mu? Kayıt olun"),
              onPressed: () {
                GirisViewModel viewModel = Provider.of<GirisViewModel>(
                  context,
                  listen: false,
                );
                viewModel.kayitSayfasiniAc(context);
              },
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            child: Text(
              "Şifremi unuttum",
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onPressed: () {
              GirisViewModel viewModel = Provider.of<GirisViewModel>(
                context,
                listen: false,
              );
              viewModel.sifreSifirla(context, _epostaController.text.trim());
            },
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Google ile giriş"),
              onPressed: () {
                GirisViewModel viewModel = Provider.of<GirisViewModel>(
                  context,
                  listen: false,
                );
                viewModel.googleIleGiris(context);
              },
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Apple ile giriş"),
              onPressed: () {
                GirisViewModel viewModel = Provider.of<GirisViewModel>(
                  context,
                  listen: false,
                );
                viewModel.appleIleGiris(context);
              },
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Telefon numarası ile giriş"),
              onPressed: () {
                GirisViewModel viewModel = Provider.of<GirisViewModel>(
                  context,
                  listen: false,
                );
                viewModel.telefonNumarasiIleGiris(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
