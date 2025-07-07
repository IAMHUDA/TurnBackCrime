import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widget/kategori_dropdown.dart';
import '../../../core/widget/foto_picker.dart';
import '../../../core/widget/maps_picker.dart';
import '../bloc/laporan_bloc.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  void resetForm() {
    _judulController.clear();
    _deskripsiController.clear();
    // Reset state BLoC
    context.read<LaporanBloc>().add(FetchKategori());
  }

  void _submitLaporan(BuildContext context, LaporanState state) {
    if (_judulController.text.isEmpty ||
        state.selectedKategori == null ||
        _deskripsiController.text.isEmpty ||
        state.selectedImage == null ||
        state.selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon lengkapi semua data sebelum mengirim laporan'),
        ),
      );
      return;
    }

    context.read<LaporanBloc>().add(SubmitLaporan());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buat Laporan')),
      body: BlocListener<LaporanBloc, LaporanState>(
        listenWhen:
            (previous, current) => previous.isSuccess != current.isSuccess,
        listener: (context, state) {
          if (state.isSuccess == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Laporan berhasil dikirim')));
            resetForm();

            // Reset isSuccess
            context.read<LaporanBloc>().add(ResetLaporanStatus());
          } else if (state.isSuccess == false) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan')));

            // Reset isSuccess
            context.read<LaporanBloc>().add(ResetLaporanStatus());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    labelText: 'Judul Laporan',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    context.read<LaporanBloc>().add(SetJudul(value));
                  },
                ),
                SizedBox(height: 16),

                KategoriDropdown(),

                SizedBox(height: 16),

                TextField(
                  controller: _deskripsiController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    context.read<LaporanBloc>().add(SetDeskripsi(value));
                  },
                ),

                SizedBox(height: 16),

                FotoPicker(),

                SizedBox(height: 16),

                MapsPicker(),

                SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<LaporanBloc, LaporanState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed:
                            state.isSubmitting
                                ? null
                                : () => _submitLaporan(context, state),
                        child:
                            state.isSubmitting
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Kirim Laporan'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
