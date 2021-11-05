import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/view_model/acilis_view_model.dart';

class AcilisSayfasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AcilisViewModel viewModel = Provider.of<AcilisViewModel>(
      context,
      listen: false,
    );
    viewModel.yonlendir(context);
    return Scaffold(
      body: Center(
        child: Text(
          "Yazar",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
