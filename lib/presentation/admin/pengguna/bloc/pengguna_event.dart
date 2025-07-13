part of 'pengguna_bloc.dart';

abstract class PenggunaEvent extends Equatable {
  const PenggunaEvent();

  @override
  List<Object?> get props => [];
}

class LoadPengguna extends PenggunaEvent {}

class TambahPengguna extends PenggunaEvent {
  final UserModel user;

  const TambahPengguna(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdatePengguna extends PenggunaEvent {
  final UserModel user;

  const UpdatePengguna(this.user);

  @override
  List<Object?> get props => [user];
}

class HapusPengguna extends PenggunaEvent {
  final int userId;

  const HapusPengguna(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SearchPengguna extends PenggunaEvent {
  final String query;

  const SearchPengguna(this.query);

  @override
  List<Object?> get props => [query];
}
