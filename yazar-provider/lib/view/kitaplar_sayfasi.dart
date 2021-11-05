import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/sabitler.dart';
import 'package:yazar/view_model/kitaplar_view_model.dart';

class KitaplarSayfasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kitaplar Sayfası"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              KitaplarViewModel viewModel = Provider.of<KitaplarViewModel>(
                context,
                listen: false,
              );
              viewModel.seciliKitaplariSil();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              KitaplarViewModel viewModel = Provider.of<KitaplarViewModel>(
                context,
                listen: false,
              );
              viewModel.cikisYap(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          KitaplarViewModel viewModel = Provider.of<KitaplarViewModel>(
            context,
            listen: false,
          );
          viewModel.kitapEkle(context);
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _buildListView();
  }

  Widget _buildListView() {
    return Column(
      children: [
        _kategoriFiltresi(),
        Expanded(
          child: Consumer<KitaplarViewModel>(
            builder: (context, viewModel, child) => ListView.builder(
              controller: viewModel.scrollController,
              itemCount: viewModel.kitaplar.length,
              itemBuilder: (BuildContext context, int index) {
                return ChangeNotifierProvider.value(
                  value: viewModel.kitaplar[index],
                  child: _buildListTile(context, index),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, int index) {
    return ListTile(
      leading: SizedBox(
        width: 48,
        height: 48,
        child: Consumer<Kitap>(
          builder: (context, kitap, child) => Image.network(
            kitap.resim ??
                "https://firebasestorage.googleapis.com"
                    "/v0/b/yazar-d3654.appspot.com/o"
                    "/flutter_logo.jpg?alt=media&token="
                    "6b76a533-397b-4d87-8e9f-f4a481e52f27",
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Consumer<Kitap>(
        builder: (context, kitap, child) => Text(kitap.isim),
      ),
      subtitle: Consumer<Kitap>(
        builder: (context, kitap, child) => Text(
          Sabitler.kategoriler[kitap.kategori] ?? "",
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              KitaplarViewModel viewModel = Provider.of<KitaplarViewModel>(
                context,
                listen: false,
              );
              viewModel.resimEkle(context, index);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              KitaplarViewModel viewModel = Provider.of<KitaplarViewModel>(
                context,
                listen: false,
              );
              //Kitap kitap = Provider.of<Kitap>(context, listen: false);

              viewModel.kitapGuncelle(context, index);
              //kitap.kitapGuncellendi();
            },
          ),
          Consumer<Kitap>(
            builder: (context, kitap, child) => Checkbox(
              value: kitap.seciliMi,
              onChanged: (bool? yeniDeger) {
                if (yeniDeger != null) {
                  KitaplarViewModel viewModel = Provider.of<KitaplarViewModel>(
                    context,
                    listen: false,
                  );
                  viewModel.kitapSecimiDegisti(index, yeniDeger);
                  kitap.seciliMi = yeniDeger;
                }
              },
            ),
          ),
        ],
      ),
      onTap: () {
        KitaplarViewModel viewModel = Provider.of<KitaplarViewModel>(
          context,
          listen: false,
        );
        viewModel.bolumlerSayfasiniAc(context, index);
      },
    );
  }

  Widget _kategoriFiltresi() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Kategori:",
          style: TextStyle(fontSize: 16),
        ),
        Consumer<KitaplarViewModel>(
          builder: (context, viewModel, child) => DropdownButton(
            value: viewModel.secilenKategori,
            onChanged: (int? yeniSecilenKategori) {
              KitaplarViewModel viewModel = Provider.of<KitaplarViewModel>(
                context,
                listen: false,
              );
              viewModel.kategoriSecimiDegisti(yeniSecilenKategori);
            },
            items: viewModel.tumKategoriler.map<DropdownMenuItem<int>>(
              (kategoriId) {
                return DropdownMenuItem<int>(
                  value: kategoriId,
                  child: Text(kategoriId == -1
                      ? "Hepsi"
                      : Sabitler.kategoriler[kategoriId] ?? ""),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}
