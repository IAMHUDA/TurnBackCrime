import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repository/komentar/komentar_repository.dart';
import '../../../data/model/komentar_model.dart';

part 'komentar_event.dart';
part 'komentar_state.dart';

class KomentarBloc extends Bloc<KomentarEvent, KomentarState> {
  final KomentarRepository repository;

  KomentarBloc(this.repository) : super(KomentarInitial()) {
    on<LoadKomentar>(_onLoadKomentar);
    on<AddKomentar>(_onAddKomentar);
    on<DeleteKomentar>(_onDeleteKomentar);
  }

  Future<void> _onLoadKomentar(
    LoadKomentar event,
    Emitter<KomentarState> emit,
  ) async {
    emit(KomentarLoading());
    try {
      final response = await repository.getByLaporan(
        idLaporan: event.idLaporan,
        page: event.page,
        limit: event.limit,
      );
      emit(KomentarLoaded(response));
    } catch (e) {
      emit(KomentarError(e.toString()));
    }
  }

  Future<void> _onAddKomentar(
  AddKomentar event,
  Emitter<KomentarState> emit,
) async {
  if (state is KomentarLoaded) {
    final currentState = state as KomentarLoaded;
    try {
      final newComment = await repository.create(
        idPengguna: event.idPengguna,
        idLaporan: event.idLaporan,
        isiKomentar: event.isiKomentar,
      );
      
      // Create new list with the new comment at the beginning
      final updatedData = [newComment, ...currentState.response.data];
      
      // Create updated meta with incremented total
      final updatedMeta = currentState.response.meta.copyWith(
        total: currentState.response.meta.total + 1,
      );
      
      emit(KomentarLoaded(
        currentState.response.copyWith(
          data: updatedData,
          meta: updatedMeta,
        ),
      ));
    } catch (e) {
      emit(KomentarError(e.toString()));
      emit(currentState);
    }
  }
}

Future<void> _onDeleteKomentar(
  DeleteKomentar event,
  Emitter<KomentarState> emit,
) async {
  if (state is KomentarLoaded) {
    final currentState = state as KomentarLoaded;
    try {
      await repository.delete(
        id: event.id,
        idPengguna: event.idPengguna,
      );
      
      // Filter out the deleted comment
      final updatedData = currentState.response.data
          .where((k) => k.id != event.id)
          .toList();
      
      // Create updated meta with decremented total
      final updatedMeta = currentState.response.meta.copyWith(
        total: currentState.response.meta.total - 1,
      );
      
      emit(KomentarLoaded(
        currentState.response.copyWith(
          data: updatedData,
          meta: updatedMeta,
        ),
      ));
    } catch (e) {
      emit(KomentarError(e.toString()));
      emit(currentState);
    }
  }
}
}