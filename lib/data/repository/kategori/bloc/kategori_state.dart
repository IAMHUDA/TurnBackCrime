part of 'kategori_bloc.dart';

abstract class KategoriState extends Equatable {
  const KategoriState();

  @override
  List<Object?> get props => [];
}

class KategoriInitial extends KategoriState {}

class KategoriLoading extends KategoriState {}

class KategoriLoaded extends KategoriState {
  final List<KategoriModel> kategoriList;

  const KategoriLoaded({required this.kategoriList});

  @override
  List<Object?> get props => [kategoriList];
}

class KategoriError extends KategoriState {
  final String message;

  const KategoriError(this.message);

  @override
  List<Object?> get props => [message];
}
