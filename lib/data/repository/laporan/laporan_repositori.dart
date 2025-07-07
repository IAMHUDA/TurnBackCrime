import 'dart:io';
import '../../../services/service_http_client.dart';

class LaporanRepository {
  final ServiceHttpClient httpClient;

  LaporanRepository(this.httpClient);

  Future<bool> submitLaporan({
    required int idPengguna,
    required String judul,
    required String deskripsi,
    required int idKategori,
    required double latitude,
    required double longitude,
    required File foto,
  }) async {
    try {
      final response = await httpClient.uploadImage('/laporan', {
        'id_pengguna': idPengguna.toString(),
        'judul': judul,
        'deskripsi': deskripsi,
        'id_kategori': idKategori.toString(),
        'lokasi_lat': latitude.toString(), // perbaiki disini
        'lokasi_long': longitude.toString(), // perbaiki disini
      }, foto);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  
}
