import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../services/service_http_client.dart';
import '../../../data/model/user_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ServiceHttpClient httpClient;

  ProfileBloc(this.httpClient) : super(ProfileInitial()) {
    on<UpdateProfile>(_onUpdateProfile);
    on<GetProfile>(_onGetProfile);
  }

  // ---------------------------
  // Update Profile
  // ---------------------------
  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileUpdating());
    try {
      final fields = {
        'nama': event.nama ?? '',
        'kontak_darurat': event.kontakDarurat,
        'email_darurat': event.emailDarurat,
      };

      final endpoint = '/pengguna/${event.userId}/profile';

      if (event.fotoPath != null && event.fotoPath!.isNotEmpty) {
        final imageFile = File(event.fotoPath!);

        final response = await httpClient.editImage(endpoint, fields, imageFile);
        final responseBody = await response.stream.bytesToString();

        print('📦 Multipart PUT response: ${response.statusCode}');
        print('📄 Body: $responseBody');

        if (response.statusCode == 200) {
          emit(ProfileUpdateSuccess());
        } else {
          emit(ProfileUpdateFailure('Gagal memperbarui profil (${response.statusCode}): $responseBody'));
        }
      } else {
        final putResponse = await httpClient.put(endpoint, fields);

        print('📦 PUT response: ${putResponse.statusCode}');
        print('📄 Body: ${putResponse.body}');

        if (putResponse.statusCode == 200) {
          emit(ProfileUpdateSuccess());
        } else {
          emit(ProfileUpdateFailure('Gagal memperbarui profil (${putResponse.statusCode}): ${putResponse.body}'));
        }
      }
    } catch (e) {
      emit(ProfileUpdateFailure('Terjadi kesalahan: $e'));
    }
  }

  // ---------------------------
  // Get Profile
  // ---------------------------
  Future<void> _onGetProfile(GetProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await httpClient.get('/pengguna/${event.userId}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final user = UserModel.fromJson(json);
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileUpdateFailure('Gagal memuat profil (${response.statusCode})'));
      }
    } catch (e) {
      emit(ProfileUpdateFailure('Terjadi kesalahan: $e'));
    }
  }
}
