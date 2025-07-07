part of 'kategori_bloc.dart';

abstract class KategoriEvent extends Equatable {
  const KategoriEvent();

  @override
  List<Object?> get props => [];
}

class FetchKategoriEvent extends KategoriEvent {}

class AddKategoriEvent extends KategoriEvent {
  final String kategori;

  const AddKategoriEvent(this.kategori);

  @override
  List<Object?> get props => [kategori];
}
