import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/service_http_client.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ServiceHttpClient httpClient;

  AuthBloc(this.httpClient) : super(AuthInitial()) {
    // Login Handler
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await httpClient.post('/auth/login', {
          'email': event.email,
          'password': event.password,
        });

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final token = responseData['token'];
          final user = responseData['user'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user['id'].toString());
          await prefs.setString('nama', user['nama']);
          await prefs.setString('email', user['email']);
          await prefs.setString('role', user['role']);
          await prefs.setString('kontak_darurat', user['kontak_darurat'] ?? '');
          await prefs.setString('alamat', user['alamat'] ?? '');
          await prefs.setString('tanggal_lahir', user['tanggal_lahir'] ?? '');

          final storage = FlutterSecureStorage();
          await storage.write(key: 'token', value: token);

          if (user['role'] == 'admin') {
            emit(AuthAdmin(nama: user['nama'], email: user['email']));
          } else if (user['kontak_darurat'] == null ||
              user['kontak_darurat'].isEmpty ||
              user['alamat'] == null ||
              user['alamat'].isEmpty ||
              user['tanggal_lahir'] == null ||
              user['tanggal_lahir'].isEmpty) {
            emit(AuthNeedsCompletion());
          } else {
            emit(AuthAuthenticated(nama: user['nama'], email: user['email']));
          }
        } else {
          String message = 'Login gagal!';
          try {
            final errorData = jsonDecode(response.body);
            message = errorData['message'] ?? message;
          } catch (_) {}
          emit(AuthError(message));
        }
      } catch (e) {
        emit(AuthError('Terjadi kesalahan: $e'));
      }
    });

    // Handler setelah profil dilengkapi
    on<AuthProfileCompleted>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();

      // Update SharedPreferences
      await prefs.setString('nama', event.nama);
      await prefs.setString('email', event.email);
      await prefs.setString('kontak_darurat', event.kontakDarurat);
      await prefs.setString('alamat', event.alamat);
      await prefs.setString('tanggal_lahir', event.tanggalLahir);

      // Emit state terbaru
      emit(AuthAuthenticated(nama: event.nama, email: event.email));
    });

    // Logout Handler
    on<AuthLogoutRequested>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final storage = FlutterSecureStorage();
      await storage.delete(key: 'token');

      emit(AuthInitial());
    });
  }
}
