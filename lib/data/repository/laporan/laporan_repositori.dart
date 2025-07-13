// '../../../data/repository/laporan/laporan_repositori.dart'
import 'dart:io';
import '../../../services/service_http_client.dart';
import '../../model/laporan_model.dart';
import 'dart:convert';

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
        'lokasi_lat': latitude.toString(),
        'lokasi_long': longitude.toString(),
      }, foto);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get semua laporan
  Future<List<LaporanModel>> getLaporan() async {
    try {
      print('LaporanRepository: Mengirim permintaan GET ke /laporan'); // <-- Tambah ini
      final response = await httpClient.get('/laporan');

      print('LaporanRepository: Menerima respons. Status Code: ${response.statusCode}'); // <-- Tambah ini
      print('LaporanRepository: Respons Body: ${response.body}'); // <-- SANGAT PENTING: Tambah ini

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);
        print('LaporanRepository: Body ter-decode: $decodedBody'); // <-- Tambah ini

        List<dynamic> data;
        // Logic untuk menangani respons yang mungkin berupa List langsung atau Map dengan kunci 'data'
        if (decodedBody is List) {
          data = decodedBody;
          print('LaporanRepository: Respons adalah List.'); // <-- Tambah ini
        } else if (decodedBody is Map && decodedBody.containsKey('data')) {
          data = decodedBody['data'];
          print('LaporanRepository: Respons adalah Map dengan kunci "data".'); // <-- Tambah ini
        } else {
          // Jika struktur JSON tidak seperti yang diharapkan
          print('LaporanRepository: ERROR - Struktur respons JSON tidak dikenali. Type: ${decodedBody.runtimeType}, Body: $decodedBody'); // <-- Debugging error
          throw Exception('Struktur respons JSON tidak dikenali.');
        }

        if (data.isEmpty) {
          print('LaporanRepository: Data laporan kosong.'); // <-- Tambah ini
        }

        return data.map((item) => LaporanModel.fromJson(item)).toList();
      } else {
        print('LaporanRepository: Gagal memuat laporan, Status Code: ${response.statusCode}, Body: ${response.body}'); // <-- Tambah ini
        throw Exception('Gagal memuat laporan: ${response.statusCode}');
      }
    } catch (e) {
      print('LaporanRepository: Error saat memuat laporan: $e'); // <-- SANGAT PENTING: Tambah ini
      throw Exception('Gagal memuat laporan: $e');
    }
  }

  Future<LaporanModel> getLaporanById(int id) async {
    try {
      final response = await httpClient.get('/laporan/$id');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LaporanModel.fromJson(data);
      } else {
        throw Exception('Gagal memuat detail laporan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}