import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../../model/user_model.dart';
import '../../../services/service_http_client.dart';

class UserRepository {
  final ServiceHttpClient _httpClient;

  UserRepository(this._httpClient);

  // ✅ Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _httpClient.get('/pengguna');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data pengguna: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan mengambil data pengguna: $e');
    }
  }

  // ✅ Get user by ID
  Future<UserModel> getUserById(int id) async {
    try {
      final response = await _httpClient.get('/pengguna/$id');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else {
        throw Exception('Gagal memuat detail pengguna: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan mengambil pengguna: $e');
    }
  }

  // ✅ Create new user
  Future<UserModel> createUser(UserModel user, {File? profileImage}) async {
    try {
      final fields = {
        'nama': user.nama,
        'email': user.email,
        'role': user.role,
        if (user.kontakDarurat != null) 'kontak_darurat': user.kontakDarurat!,
        if (user.alamat != null) 'alamat': user.alamat!,
        if (user.tanggalLahir != null) 'tanggal_lahir': user.tanggalLahir!,
        if (user.emailDarurat != null) 'email_darurat': user.emailDarurat!,
      };

      late http.StreamedResponse response;
      if (profileImage != null) {
        response = await _httpClient.uploadImage('/users', fields, profileImage);
      } else {
        response = await _httpClient.uploadImage('/users', fields, File(''));
      }

      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        return UserModel.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Gagal menambahkan pengguna: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan saat menambah pengguna: $e');
    }
  }

  // ✅ Update user
  Future<UserModel> updateUser(UserModel user, {File? profileImage}) async {
    try {
      final fields = {
        'nama': user.nama,
        'email': user.email,
        'role': user.role,
        if (user.kontakDarurat != null) 'kontak_darurat': user.kontakDarurat!,
        if (user.alamat != null) 'alamat': user.alamat!,
        if (user.tanggalLahir != null) 'tanggal_lahir': user.tanggalLahir!,
        if (user.emailDarurat != null) 'email_darurat': user.emailDarurat!,
      };

      late http.StreamedResponse response;
      if (profileImage != null) {
        response = await _httpClient.editImage('/users/${user.id}', fields, profileImage);
      } else {
        response = await _httpClient.editImage('/users/${user.id}', fields, File(''));
      }

      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Gagal memperbarui pengguna: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan saat update pengguna: $e');
    }
  }

  // ✅ Delete user
  Future<void> deleteUser(int id) async {
    try {
      final response = await _httpClient.delete('/users/$id');
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus pengguna: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan saat menghapus pengguna: $e');
    }
  }

  // ✅ Search user
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _httpClient.get('/users/search?q=$query');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mencari pengguna: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan saat mencari pengguna: $e');
    }
  }
}
