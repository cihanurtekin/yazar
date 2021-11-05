import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/view_model/telefon_ile_giris_view_model.dart';

class TelefonIleGirisSayfasi extends StatelessWidget {
  TextEditingController _telefonNumarasiController = TextEditingController();
  TextEditingController _dogrulamaKoduController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Telefon Numarası ile Giriş"),
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
            controller: _telefonNumarasiController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Telefon numarası",
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Doğrulama kodu gönder"),
              onPressed: () {
                TelefonIleGirisViewModel viewModel =
                    Provider.of<TelefonIleGirisViewModel>(
                  context,
                  listen: false,
                );
                viewModel.dogrulamaKoduGonder(
                  context,
                  _telefonNumarasiController.text.trim(),
                );
              },
            ),
          ),
          SizedBox(height: 48),
          Consumer<TelefonIleGirisViewModel>(
            builder: (context, viewModel, child) {
              return Visibility(
                visible: viewModel.dogrulamaBolumunuGoster,
                child: child!,
              );
            },
            child: Column(
              children: [
                TextField(
                  controller: _dogrulamaKoduController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Doğrulama kodu",
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("Doğrulama kodunu onayla"),
                    onPressed: () {
                      TelefonIleGirisViewModel viewModel =
                          Provider.of<TelefonIleGirisViewModel>(
                        context,
                        listen: false,
                      );
                      viewModel.dogrulamaKodunuOnayla(
                        context,
                        _dogrulamaKoduController.text.trim(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Diğer giriş yöntemleri"),
              onPressed: () {
                TelefonIleGirisViewModel viewModel =
                    Provider.of<TelefonIleGirisViewModel>(
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
