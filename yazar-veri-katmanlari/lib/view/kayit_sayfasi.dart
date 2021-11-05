import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/view_model/kayit_view_model.dart';

class KayitSayfasi extends StatelessWidget {
  TextEditingController _adSoyadController = TextEditingController();
  TextEditingController _epostaController = TextEditingController();
  TextEditingController _sifreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kayıt Sayfası"),
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
            controller: _adSoyadController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Ad - Soyad",
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _epostaController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "E - posta",
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
              child: Text("Kayıt Ol"),
              onPressed: () {
                KayitViewModel viewModel = Provider.of<KayitViewModel>(
                  context,
                  listen: false,
                );
                viewModel.epostaVeSifreIleKayit(
                  context,
                  _adSoyadController.text.trim(),
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
              child: Text("Zaten hesabınız var mı? Giriş yapın"),
              onPressed: () {
                KayitViewModel viewModel = Provider.of<KayitViewModel>(
                  context,
                  listen: false,
                );
                viewModel.girisSayfasiniAc(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
