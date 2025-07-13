// services/service_http_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Tetap gunakan ini

// Hapus import ini karena kita tidak jadi menggunakan ServiceStorage
// import 'service_storage.dart';

class ServiceHttpClient {
  final String _baseUrl = 'http://10.0.2.2:5000/api';

  // Kembali menggunakan FlutterSecureStorage secara internal
  final _storage = const FlutterSecureStorage();

  // Kembalikan constructor ke tanpa parameter
  ServiceHttpClient(); // <-- Perbaikan di sini

  // Metode untuk menyimpan token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
    print('ServiceHttpClient: Token saved internally: $token'); // Debugging
  }

  // Metode untuk menghapus token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
    print('ServiceHttpClient: Token deleted internally'); // Debugging
  }

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'token');
    print('ServiceHttpClient: Token retrieved internally: $token'); // Debugging
    return token;
  }

  // --- PERBAIKAN PENTING DI SINI: get() untuk Query Parameters ---
  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final token = await _getToken();

    Uri uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      // Baris ini akan mencetak queryParams yang diterima oleh HttpClient
      print('ServiceHttpClient: Menerima queryParams: $queryParams');

      // Ini yang akan menambahkan parameter ke URL
      uri = uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
    }

    // LOG INI AKAN MENUNJUKKAN URL LENGKAP DENGAN PARAMETER JIKA BERHASIL
    print('ServiceHttpClient: Mengirim permintaan GET ke: $uri');
    print('ServiceHttpClient: Authorization Header: Bearer ${token ?? "No Token Provided"}');

    final response = await http.get(
      uri, // <--- Pastikan ini menggunakan URI yang sudah dimodifikasi
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
        'Content-Type': 'application/json',
      },
    );
    print('ServiceHttpClient: Menerima respons GET. Status Code: ${response.statusCode}');
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.StreamedResponse> uploadImage(String endpoint, Map<String, String> fields, File imageFile) async {
    final token = await _getToken();
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));
    request.headers['Authorization'] = 'Bearer ${token ?? ''}';
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));

    return await request.send();
  }

  Future<http.StreamedResponse> editImage(String endpoint, Map<String, String> fields, File imageFile) async {
    final token = await _getToken();
    var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl$endpoint'));
    request.headers['Authorization'] = 'Bearer ${token ?? ''}';

    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path)); // ⚠️ nama 'foto' harus sesuai di multer

    return await request.send();
  }

  // Metode PATCH yang Anda tambahkan sebelumnya, saya masukkan kembali di sini
  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return response;
  }
}