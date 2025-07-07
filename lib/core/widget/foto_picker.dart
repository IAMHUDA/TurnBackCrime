import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../presentation/laporan/bloc/laporan_bloc.dart';


class FotoPicker extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaporanBloc, LaporanState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto Bukti',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            state.selectedImage == null
                ? Text('Belum ada foto yang dipilih.')
                : Image.file(state.selectedImage!, height: 200),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                if (photo != null) {
                  context.read<LaporanBloc>().add(SelectImage(photo.path));
                }
              },
              child: Text('Ambil Foto'),
            ),
          ],
        );
      },
    );
  }
}
