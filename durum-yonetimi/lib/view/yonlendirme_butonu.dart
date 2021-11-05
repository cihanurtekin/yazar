import 'package:durum_yonetimi/view_model/birinci_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YonlendirmeButonu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text("İkinci Sayfayı Aç"),
      onPressed: () {
        BirinciViewModel viewModel = Provider.of<BirinciViewModel>(
          context,
          listen: false,
        );
        viewModel.ikinciSayfayiAc(context);
      },
    );
  }
}
