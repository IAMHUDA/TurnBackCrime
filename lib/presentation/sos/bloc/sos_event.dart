part of 'sos_bloc.dart';

abstract class SOSEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AktifkanSOS extends SOSEvent {
  final int idPengguna;
  final String nama;
  final String emailTujuan;

  AktifkanSOS({required this.idPengguna, required this.nama, required this.emailTujuan,});
  
  @override
  List<Object> get props => [idPengguna, nama, emailTujuan];
}
