import 'package:flutter/material.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/veri_tabani/uzak_veri_tabani.dart';
import 'package:yazar/veri_tabani/yerel_veri_tabani.dart';

class BolumDetaySayfasi extends StatelessWidget {
  final Bolum bolum;

  BolumDetaySayfasi(this.bolum);

  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();
  UzakVeriTabani _uzakVeriTabani = UzakVeriTabani();

  TextEditingController _icerikController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bolum.baslik),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _icerigiKaydet,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    _icerikController.text = bolum.icerik;
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

  void _icerigiKaydet() async {
    bolum.icerik = _icerikController.text;
    await _uzakVeriTabani.updateBolum(bolum);
  }
}
