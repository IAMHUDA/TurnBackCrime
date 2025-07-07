import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/laporan/bloc/laporan_bloc.dart';
import '../../data/model/kategori_model.dart';

class KategoriDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaporanBloc, LaporanState>(
      builder: (context, state) {
        if (state.isLoadingKategori) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<KategoriModel>(
              value: state.selectedKategori,
              items: state.kategoriList.map((kategori) {
                return DropdownMenuItem<KategoriModel>(
                  value: kategori,
                  child: Text(kategori.nama), // Pastikan ambil nama kategori
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<LaporanBloc>().add(SelectKategori(value));
                }
              },
              decoration: InputDecoration(
                labelText: 'Pilih Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _showTambahKategoriDialog(context);
              },
              child: Text('Tambah Kategori Baru'),
            ),
          ],
        );
      },
    );
  }

  void _showTambahKategoriDialog(BuildContext context) {
    final TextEditingController _kategoriController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Kategori Baru'),
        content: TextField(
          controller: _kategoriController,
          decoration: InputDecoration(
            hintText: 'Masukkan nama kategori',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_kategoriController.text.isNotEmpty) {
                context.read<LaporanBloc>().add(AddKategori(_kategoriController.text));
              }
              Navigator.pop(context);
            },
            child: Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
