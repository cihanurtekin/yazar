import 'package:durum_yonetimi/view/yonlendirme_butonu.dart';
import 'package:durum_yonetimi/view_model/birinci_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BirinciSayfa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Sayfa baştan oluşturuldu.");
    return Scaffold(
      appBar: AppBar(
        title: Text("Birinci Sayfa"),
      ),
      body: Consumer<BirinciViewModel>(
        builder: (context, viewModel, child) {
          print("Container - Consumer oluşturuldu.");
          return Container(
            color: viewModel.renk,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlutterLogo(size: 96),
            _buildBaslik(),
            _buildDegistir(context),
            _buildRenkDegistir(context),
            YonlendirmeButonu(),
            _buildCheckboxRow()
          ],
        ),
      ),
    );
  }

  Widget _buildBaslik() {
    print("Başlık oluşturuldu.");
    return Consumer<BirinciViewModel>(
      builder: (context, viewModel, child) {
        print("Başlık - Consumer oluşturuldu.");
        return Text(
          viewModel.yazi,
          style: TextStyle(fontSize: 28),
        );
      },
    );
  }

  Widget _buildDegistir(BuildContext context) {
    print("Buton oluşturuldu.");
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text("Yazıyı Değiştir"),
        onPressed: () {
          BirinciViewModel viewModel = Provider.of<BirinciViewModel>(
            context,
            listen: false,
          );
          viewModel.butonaTiklandi();
        },
      ),
    );
  }

  Widget _buildRenkDegistir(BuildContext context) {
    print("Renk Değiştir Butonu oluşturuldu.");
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text("Renk Değiştir"),
        onPressed: () {
          BirinciViewModel viewModel = Provider.of<BirinciViewModel>(
            context,
            listen: false,
          );
          viewModel.renkDegistir();
        },
      ),
    );
  }

  Widget _buildCheckboxRow() {
    print("Checkbox satırı oluşturuldu.");
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Checkbox:",
          style: TextStyle(fontSize: 18),
        ),
        Consumer<BirinciViewModel>(builder: (context, viewModel, child) {
          print("Checkbox - Consumer oluşturuldu.");
          return Checkbox(
            value: viewModel.checkboxSeciliMi,
            onChanged: (bool? yeniDeger) {
              viewModel.checkboxDegeriDegisti(yeniDeger);
            },
          );
        }),
      ],
    );
  }
}
