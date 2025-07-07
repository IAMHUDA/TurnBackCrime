abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthLogoutRequested extends AuthEvent {}

class AuthProfileCompleted extends AuthEvent {
  final String nama;
  final String email;
  final String kontakDarurat;
  final String alamat;
  final String tanggalLahir;

  AuthProfileCompleted({
    required this.nama,
    required this.email,
    required this.kontakDarurat,
    required this.alamat,
    required this.tanggalLahir,
  });
}

