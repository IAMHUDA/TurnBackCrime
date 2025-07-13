import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/model/laporan_model.dart';
import '../bloc/laporan_detail_bloc.dart';
import '../bloc/laporan_detail_event.dart';
import '../bloc/laporan_detail_state.dart';

class DetailLaporanPage extends StatelessWidget {
  final int laporanId;

  const DetailLaporanPage({super.key, required this.laporanId});

  @override
  Widget build(BuildContext context) {
    // Langsung memanggil event, karena Bloc sudah disediakan di main.dart
    context.read<LaporanDetailBloc>().add(FetchLaporanDetail(laporanId));

    return Scaffold(
      appBar: AppBar(title: Text('Detail Laporan')),
      body: BlocBuilder<LaporanDetailBloc, LaporanDetailState>(
        builder: (context, state) {
          if (state is LaporanDetailLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is LaporanDetailLoaded) {
            return _buildDetailContent(state.laporan);
          } else if (state is LaporanDetailError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return Center(child: Text('Data tidak ditemukan.'));
        },
      ),
    );
  }

  Widget _buildDetailContent(LaporanModel laporan) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            laporan.judul ?? 'Tanpa Judul',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(laporan.deskripsi ?? 'Tanpa Deskripsi'),
          SizedBox(height: 16),
          if (laporan.foto != null)
            Image.network(
              'http://10.0.2.2:5000/uploads/${laporan.foto}',
              height: 200,
              fit: BoxFit.cover,
            )
          else
            Text('Tidak ada foto'),
          SizedBox(height: 16),
          if (laporan.lokasiLat != null && laporan.lokasiLong != null)
            Container(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(laporan.lokasiLat!, laporan.lokasiLong!),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('lokasi_laporan'),
                    position: LatLng(laporan.lokasiLat!, laporan.lokasiLong!),
                    infoWindow: InfoWindow(title: laporan.judul ?? 'Lokasi Laporan'),
                  ),
                },
              ),
            )
          else
            Text('Lokasi tidak tersedia'),
          SizedBox(height: 16),
          Text('Status: ${laporan.status}'),
          SizedBox(height: 8),
          Text('Dibuat pada: ${laporan.createdAt}'),
        ],
      ),
    );
  }
}
