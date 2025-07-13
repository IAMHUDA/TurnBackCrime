part of 'pengguna_bloc.dart';

abstract class PenggunaState extends Equatable {
  const PenggunaState();

  @override
  List<Object?> get props => [];
}

class PenggunaInitial extends PenggunaState {}

class PenggunaLoading extends PenggunaState {}

class PenggunaLoaded extends PenggunaState {
  final List<UserModel> pengguna;

  const PenggunaLoaded(this.pengguna);

  @override
  List<Object?> get props => [pengguna];
}

class PenggunaError extends PenggunaState {
  final String message;

  const PenggunaError(this.message);

  @override
  List<Object?> get props => [message];
}
