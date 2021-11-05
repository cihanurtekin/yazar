import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/view_model/bolum_detay_view_model.dart';

class BolumDetaySayfasi extends StatelessWidget {
  TextEditingController _icerikController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    BolumDetayViewModel viewModel = Provider.of<BolumDetayViewModel>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.bolum.baslik),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              viewModel.icerigiKaydet(_icerikController.text.trim());
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    BolumDetayViewModel viewModel = Provider.of<BolumDetayViewModel>(
      context,
      listen: false,
    );
    _icerikController.text = viewModel.bolum.icerik;
    return Container(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        controller: _icerikController,
        maxLines: 1000,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
