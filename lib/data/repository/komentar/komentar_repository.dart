import 'dart:convert';
import '../../../services/service_http_client.dart';
import '../../model/komentar_model.dart';

class KomentarRepository {
  final ServiceHttpClient httpClient;

  KomentarRepository(this.httpClient);

  Future<KomentarResponse> getByLaporan({
    required int idLaporan,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await httpClient.get(
      '/komentar/laporan/$idLaporan?page=$page&limit=$limit',
    );

    if (response.statusCode == 200) {
      return KomentarResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}');
    }
  }

  Future<Komentar> create({
    required int idPengguna,
    required int idLaporan,
    required String isiKomentar,
  }) async {
    final response = await httpClient.post(
      '/komentar',
      {
        'id_pengguna': idPengguna,
        'id_laporan': idLaporan,
        'isi_komentar': isiKomentar,
      },
    );

    if (response.statusCode == 201) {
      return Komentar.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to create comment: ${response.statusCode}');
    }
  }

  Future<bool> delete({
    required int id,
    required int idPengguna,
  }) async {
    final response = await httpClient.delete(
      '/komentar/$id',
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete comment: ${response.statusCode}');
    }
  }
}