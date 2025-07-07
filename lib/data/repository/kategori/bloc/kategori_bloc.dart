import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../model/kategori_model.dart';
import '../kategori_repository.dart';

part 'kategori_event.dart';
part 'kategori_state.dart';

class KategoriBloc extends Bloc<KategoriEvent, KategoriState> {
  final KategoriRepository kategoriRepository;

  KategoriBloc({required this.kategoriRepository}) : super(KategoriInitial()) {
    on<FetchKategoriEvent>(_onFetchKategori);
    on<AddKategoriEvent>(_onAddKategori);
  }

  Future<void> _onFetchKategori(FetchKategoriEvent event, Emitter<KategoriState> emit) async {
    emit(KategoriLoading());
    try {
      final kategoriList = await kategoriRepository.getAllKategori();
      emit(KategoriLoaded(kategoriList: kategoriList));
    } catch (e) {
      emit(KategoriError('Gagal memuat kategori'));
    }
  }

  Future<void> _onAddKategori(AddKategoriEvent event, Emitter<KategoriState> emit) async {
    try {
      await kategoriRepository.createKategori(event.kategori);
      add(FetchKategoriEvent()); // Refresh data
    } catch (e) {
      emit(KategoriError('Gagal menambah kategori'));
    }
  }
}
