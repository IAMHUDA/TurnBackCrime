// ---------------------------
// Profile Events
// ---------------------------
part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  
  @override
  List<Object?> get props => [];
}

class GetProfile extends ProfileEvent {
  final int userId;
  
  const GetProfile(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  final int userId;
  final String nama;
  final String kontakDarurat;
  final String emailDarurat;
  final String? fotoPath; // Path lokal gambar
  
  const UpdateProfile({
    required this.userId,
    required this.nama,
    required this.kontakDarurat,
    required this.emailDarurat,
    this.fotoPath,
  });
  
  @override
  List<Object?> get props => [userId, nama, kontakDarurat, emailDarurat, fotoPath];
}