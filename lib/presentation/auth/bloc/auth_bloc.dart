import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/service_http_client.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../data/model/user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ServiceHttpClient httpClient;

  AuthBloc(this.httpClient) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await httpClient.post('/auth/login', {
          'email': event.email,
          'password': event.password,
        });

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final token = responseData['token'];
          final userData = responseData['user'];
          final user = UserModel.fromJson(userData);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user.id.toString());
          await prefs.setString('nama', user.nama);
          await prefs.setString('email', user.email);
          await prefs.setString('role', user.role);
          await prefs.setString('kontak_darurat', user.kontakDarurat ?? '');
          await prefs.setString('alamat', user.alamat ?? '');
          await prefs.setString('tanggal_lahir', user.tanggalLahir ?? '');

          final storage = FlutterSecureStorage();
          await storage.write(key: 'token', value: token);

          if (user.role == 'admin') {
            emit(AuthAdmin(user: user));
          } else if (user.kontakDarurat == null ||
              user.kontakDarurat!.isEmpty ||
              user.alamat == null ||
              user.alamat!.isEmpty ||
              user.tanggalLahir == null ||
              user.tanggalLahir!.isEmpty) {
            emit(AuthNeedsCompletion());
          } else {
            emit(AuthAuthenticated(user: user));
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

    on<AuthProfileCompleted>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('nama', event.nama);
      await prefs.setString('email', event.email);
      await prefs.setString('kontak_darurat', event.kontakDarurat);
      await prefs.setString('alamat', event.alamat);
      await prefs.setString('tanggal_lahir', event.tanggalLahir);

      final user = UserModel(
        id: int.parse(prefs.getString('userId') ?? '0'),
        nama: event.nama,
        email: event.email,
        role: prefs.getString('role') ?? 'user',
        kontakDarurat: event.kontakDarurat,
        alamat: event.alamat,
        tanggalLahir: event.tanggalLahir,
      );

      emit(AuthAuthenticated(user: user));
    });

    on<AuthLogoutRequested>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final storage = FlutterSecureStorage();
      await storage.delete(key: 'token');

      emit(AuthInitial());
    });
  }
}
