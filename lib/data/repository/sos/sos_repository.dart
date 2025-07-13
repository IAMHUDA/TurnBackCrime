import '../../../services/service_http_client.dart';

class SOSRepository {
  final ServiceHttpClient httpClient;

  SOSRepository(this.httpClient);

  Future<void> kirimSOS({
    required int idPengguna,
    required double lat,
    required double long,
    required String emailTujuan,
  }) async {
    final response = await httpClient.post('/sos', {
      'id_pengguna': idPengguna,
      'lokasi_lat': lat,
      'lokasi_long': long,
       'email_tujuan': emailTujuan,
    });

    if (response.statusCode != 200) {
      throw Exception('Gagal mengirim SOS ke server');
    }
  }
}
