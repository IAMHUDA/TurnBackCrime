import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dashboard/components/report_card.dart';
import '../bloc/riwayat_laporan_bloc.dart';
import '../bloc/riwayat_laporan_event.dart';
import '../bloc/riwayat_laporan_state.dart';
import '../../laporan_detail/pages/laporan_detail_page.dart';

class RiwayatLaporanPage extends StatelessWidget {
  const RiwayatLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Laporan')),
      body: BlocBuilder<RiwayatLaporanBloc, RiwayatLaporanState>(
        builder: (context, state) {
          if (state is RiwayatLaporanLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is RiwayatLaporanLoaded) {
            if (state.laporanList.isEmpty) {
              return Center(child: Text('Belum ada laporan.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<RiwayatLaporanBloc>().add(FetchRiwayatLaporan());
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: state.laporanList.length,
                itemBuilder: (context, index) {
                  final laporan = state.laporanList[index];

                  // Jika ID null, lewati item ini
                  if (laporan.id == null) return SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailLaporanPage(
                            laporanId: laporan.id!, // Kirim ID laporan
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ReportCard(
                        title: laporan.judul ?? 'Tidak ada judul',
                        location: laporan.lokasiLat != null && laporan.lokasiLong != null
                            ? 'Lat: ${laporan.lokasiLat}, Long: ${laporan.lokasiLong}'
                            : 'Lokasi tidak tersedia',
                        time: laporan.createdAt ?? '',
                        description: laporan.deskripsi ?? '',
                        totalKomentar: 0, // Data komentar bisa ditambahkan nanti
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is RiwayatLaporanError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Center(child: Text('Tidak ada data.'));
          }
        },
      ),
    );
  }
}
