import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/model/user_model.dart';
import '../../../../data/repository/pengguna/user_repository.dart';

part 'pengguna_event.dart';
part 'pengguna_state.dart';

class PenggunaBloc extends Bloc<PenggunaEvent, PenggunaState> {
  final UserRepository repository;

  PenggunaBloc(this.repository) : super(PenggunaInitial()) {
    on<LoadPengguna>(_onLoadPengguna);
    on<TambahPengguna>(_onTambahPengguna);
    on<UpdatePengguna>(_onUpdatePengguna);
    on<HapusPengguna>(_onHapusPengguna);
    on<SearchPengguna>(_onSearchPengguna);
  }

  Future<void> _onLoadPengguna(LoadPengguna event, Emitter<PenggunaState> emit) async {
    emit(PenggunaLoading());
    try {
      final users = await repository.getAllUsers();
      emit(PenggunaLoaded(users));
    } catch (e) {
      emit(PenggunaError(e.toString()));
    }
  }

  Future<void> _onTambahPengguna(TambahPengguna event, Emitter<PenggunaState> emit) async {
    try {
      await repository.createUser(event.user);
      add(LoadPengguna());
    } catch (e) {
      emit(PenggunaError(e.toString()));
    }
  }

  Future<void> _onUpdatePengguna(UpdatePengguna event, Emitter<PenggunaState> emit) async {
    try {
      await repository.updateUser(event.user);
      add(LoadPengguna());
    } catch (e) {
      emit(PenggunaError(e.toString()));
    }
  }

  Future<void> _onHapusPengguna(HapusPengguna event, Emitter<PenggunaState> emit) async {
    try {
      await repository.deleteUser(event.userId);
      add(LoadPengguna());
    } catch (e) {
      emit(PenggunaError(e.toString()));
    }
  }

  Future<void> _onSearchPengguna(SearchPengguna event, Emitter<PenggunaState> emit) async {
    emit(PenggunaLoading());
    try {
      final users = await repository.searchUsers(event.query);
      emit(PenggunaLoaded(users));
    } catch (e) {
      emit(PenggunaError(e.toString()));
    }
  }
}
