import 'dart:convert';
import '../../model/kategori_model.dart';
import '../../../services/service_http_client.dart';

class KategoriRepository {
  final ServiceHttpClient httpClient;

  KategoriRepository(this.httpClient);

  Future<List<KategoriModel>> getAllKategori() async {
    final response = await httpClient.get('/kategori');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => KategoriModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  Future<void> createKategori(String namaKategori) async {
    final response = await httpClient.post('/kategori', {
      'nama_kategori': namaKategori,
    });

    if (response.statusCode != 201) {
      throw Exception('Gagal menambah kategori');
    }
  }
}
