// lib/domain/repositories/kelola_laporan_repository.dart
// (atau sesuaikan path jika struktur Anda berbeda, misal di data/repositories)

import 'dart:io';
import 'dart:convert';
import '../../../data/model/kelola_laporan_model.dart'; // Sesuaikan path model
import '../../../services/service_http_client.dart'; // Sesuaikan path service_http_client

class KelolaLaporanRepository {
  final ServiceHttpClient httpClient;

  KelolaLaporanRepository(this.httpClient);

  // Ambil semua laporan (untuk admin) dengan dukungan pencarian dan filter
  Future<List<KelolaLaporanModel>> getKelolaLaporan({
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }
      if (statusFilter != null && statusFilter.isNotEmpty) {
        queryParams['status'] = statusFilter;
      }

      // --- INI ADALAH BARIS KRUSIAL ---
      // Pastikan Anda meneruskan `queryParams` di sini sebagai named parameter
      final response = await httpClient.get(
        '/laporan',
        queryParams: queryParams, // <--- PASTIKAN INI ADA DAN TIDAK ADA TYPO
      );
      // --- AKHIR BARIS KRUSIAL ---

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => KelolaLaporanModel.fromJson(item)).toList();
      } else {
        String errorMessage = 'Gagal memuat laporan: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          print('Error decoding error response body in Repository: $e');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error in getKelolaLaporan of Repository: $e');
      throw Exception('Gagal memuat laporan: $e');
    }
  }

  // Tambah laporan
  Future<void> addKelolaLaporan(KelolaLaporanModel laporan, File foto) async { // Parameter disederhanakan menggunakan model
    try {
      final fields = {
        'id_pengguna': laporan.idPengguna.toString(),
        'judul': laporan.judul ?? '', // Pastikan tidak null
        'deskripsi': laporan.deskripsi ?? '', // Pastikan tidak null
        'id_kategori': laporan.idKategori.toString(),
        'lokasi_lat': laporan.lokasiLat?.toString() ?? '', // Pastikan tidak null
        'lokasi_long': laporan.lokasiLong?.toString() ?? '', // Pastikan tidak null
        'status': laporan.status ?? 'Baru', // Pastikan status diset, default 'Baru'
      };
      // Asumsi httpClient.uploadImage menerima Map<String, String> fields
      final response = await httpClient.uploadImage('/laporan', fields, foto);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseBody);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal menambahkan laporan.');
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        String errorMessage = 'Gagal menambahkan laporan: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = json.decode(responseBody);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // ignore error jika body bukan JSON
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menambahkan laporan: $e');
    }
  }

  // Update laporan (admin bisa update semua field)
  Future<void> updateKelolaLaporan(KelolaLaporanModel laporan, File? foto) async { // Parameter disederhanakan menggunakan model
    try {
      final fields = {
        'id_pengguna': laporan.idPengguna.toString(),
        'judul': laporan.judul ?? '',
        'deskripsi': laporan.deskripsi ?? '',
        'id_kategori': laporan.idKategori.toString(),
        'status': laporan.status ?? 'Baru', // Pastikan status diset
        'lokasi_lat': laporan.lokasiLat?.toString() ?? '',
        'lokasi_long': laporan.lokasiLong?.toString() ?? '',
        '_method': 'PUT', // Penting untuk Laravel jika menggunakan POST dengan form-data untuk PUT
      };

      if (foto != null) {
        final response = await httpClient.editImage('/laporan/${laporan.id}', fields, foto);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody = await response.stream.bytesToString();
          final Map<String, dynamic> data = json.decode(responseBody);
          if (data['success'] != true) {
            throw Exception(data['message'] ?? 'Gagal memperbarui laporan (dengan foto).');
          }
        } else {
          final responseBody = await response.stream.bytesToString();
          String errorMessage = 'Gagal memperbarui laporan (dengan foto): ${response.statusCode}';
          try {
            final Map<String, dynamic> errorData = json.decode(responseBody);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            // ignore error jika body bukan JSON
          }
          throw Exception(errorMessage);
        }
      } else {
        // Jika tidak ada foto baru, gunakan metode PUT biasa (application/json)
        // Data harus dikirim sebagai JSON, bukan form-data jika tidak ada file
        final body = laporan.toJson(); // Gunakan toJson dari model
        // Hapus 'foto' jika ada karena tidak diupdate
        body.remove('foto');
        body.remove('created_at'); // Biasanya tidak dikirim saat update
        body.remove('updated_at'); // Biasanya tidak dikirim saat update
        body.remove('nama_kategori'); // Tidak perlu dikirim saat update
        body.remove('total_komentar'); // Tidak perlu dikirim saat update

        final response = await httpClient.put('/laporan/${laporan.id}', body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['success'] != true) {
            throw Exception(data['message'] ?? 'Gagal memperbarui laporan (tanpa foto).');
          }
        } else {
          String errorMessage = 'Gagal memperbarui laporan (tanpa foto): ${response.statusCode}';
          try {
            final Map<String, dynamic> errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            // ignore error jika body bukan JSON
          }
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memperbarui laporan: $e');
    }
  }

// Update status laporan (endpoint khusus admin)
Future<void> updateKelolaLaporanStatus({
  required int id,
  required String status,
}) async {
  try {
    final body = {'status': status};
    print('KelolaLaporanRepository: Mengirim permintaan PUT ke /laporan/$id/status dengan body: $body');
    final response = await httpClient.patch('/laporan/$id/status', body); // Atau httpClient.patch jika Anda mengubahnya

    print('KelolaLaporanRepository: Menerima respons UPDATE STATUS. Status Code: ${response.statusCode}');
    print('KelolaLaporanRepository: Respons Body UPDATE STATUS: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // HAPUS ATAU UBAH LOGIKA INI:
      // if (data['success'] != true) {
      //   print('KelolaLaporanRepository: API mengindikasikan kegagalan update status: ${data['message']}');
      //   throw Exception(data['message'] ?? 'Gagal memperbarui status laporan.');
      // }

      // Cukup cetak pesan sukses dan kembalikan
      print('KelolaLaporanRepository: Status laporan berhasil diupdate: ${data['message']}');
      // Tidak perlu melempar exception di sini karena operasi sukses
    } else {
      String errorMessage = 'Gagal memperbarui status laporan: ${response.statusCode}';
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (e) {
        print('KelolaLaporanRepository: Respons body bukan JSON saat update status gagal.');
      }
      print('KelolaLaporanRepository: Gagal memperbarui status laporan (non-200): $errorMessage');
      throw Exception(errorMessage); // Ini tetap untuk error non-200
    }
  } catch (e) {
    print('KelolaLaporanRepository: Terjadi kesalahan saat memperbarui status laporan: $e');
    throw Exception('Terjadi kesalahan saat memperbarui status laporan: $e');
  }
}

  // Hapus laporan
  // data/repository/laporan/kelola_laporan_repository.dart
// ...
Future<void> deleteKelolaLaporan(int id) async {
  try {
    print('KelolaLaporanRepository: Mengirim permintaan DELETE ke /laporan/$id');
    final response = await httpClient.delete('/laporan/$id');

    print('KelolaLaporanRepository: Menerima respons DELETE. Status Code: ${response.statusCode}');
    print('KelolaLaporanRepository: Respons Body DELETE: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content juga berarti sukses hapus
      print('KelolaLaporanRepository: Laporan berhasil dihapus dari API.');
      return; // Sukses, tidak perlu throw
    } else {
      final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
      print('KelolaLaporanRepository: Gagal menghapus laporan: ${response.statusCode}, Error: $errorMessage');
      throw Exception('Gagal menghapus laporan: ${errorMessage}');
    }
  } catch (e) {
    print('KelolaLaporanRepository: Error saat menghapus laporan: $e');
    throw Exception('Error menghapus laporan: $e');
  }
}

}