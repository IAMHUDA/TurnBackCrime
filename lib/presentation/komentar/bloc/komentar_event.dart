part of 'komentar_bloc.dart';

abstract class KomentarEvent extends Equatable {
  const KomentarEvent();

  @override
  List<Object> get props => [];
}

class LoadKomentar extends KomentarEvent {
  final int idLaporan;
  final int page;
  final int limit;

  const LoadKomentar({
    required this.idLaporan,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object> get props => [idLaporan, page, limit];
}

class AddKomentar extends KomentarEvent {
  final int idPengguna;
  final int idLaporan;
  final String isiKomentar;

  const AddKomentar({
    required this.idPengguna,
    required this.idLaporan,
    required this.isiKomentar,
  });

  @override
  List<Object> get props => [idPengguna, idLaporan, isiKomentar];
}

class DeleteKomentar extends KomentarEvent {
  final int id;
  final int idPengguna;

  const DeleteKomentar({
    required this.id,
    required this.idPengguna,
  });

  @override
  List<Object> get props => [id, idPengguna];
}