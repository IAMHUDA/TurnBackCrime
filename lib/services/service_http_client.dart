import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServiceHttpClient {
  final String _baseUrl = 'http://10.0.2.2:5000/api'; // Ganti sesuai server kamu
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<http.Response> get(String endpoint) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
        'Content-Type': 'application/json',
      },
    );
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
}
