

class UserModel {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? kontakDarurat;
  final String? alamat;
  final String? tanggalLahir;
  final String? emailDarurat;
  final String? fotoProfile;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.kontakDarurat,
    this.alamat,
    this.tanggalLahir,
    this.emailDarurat,
    this.fotoProfile
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final baseUrl = 'http://10.0.2.2:5000/uploads/';
    return UserModel(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      role: json['role'],
      kontakDarurat: json['kontak_darurat'],
      alamat: json['alamat'],
      tanggalLahir: json['tanggal_lahir'],
      emailDarurat: json['email_darurat'],
      fotoProfile: json['foto_profile'] != null
          ? baseUrl + json['foto_profile']
          : null,
    );
  }
}
