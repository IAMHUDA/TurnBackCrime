// lib/presentation/admin/laporan/bloc/kelola_laporan_state.dart

import 'package:equatable/equatable.dart';
import '../../../../data/model/kelola_laporan_model.dart';

abstract class KelolaLaporanState extends Equatable {
  const KelolaLaporanState();

  @override
  List<Object?> get props => [];
}

class KelolaLaporanInitial extends KelolaLaporanState {}

class KelolaLaporanLoading extends KelolaLaporanState {}

class KelolaLaporanLoaded extends KelolaLaporanState {
  final List<KelolaLaporanModel> laporanList;
  final String? currentSearchQuery; // Tambahkan ini
  final String? currentStatusFilter; // Tambahkan ini

  const KelolaLaporanLoaded({
    required this.laporanList,
    this.currentSearchQuery,
    this.currentStatusFilter,
  });

  @override
  List<Object?> get props => [laporanList, currentSearchQuery, currentStatusFilter];

  // Tambahkan copyWith untuk kemudahan pembaruan state
  KelolaLaporanLoaded copyWith({
    List<KelolaLaporanModel>? laporanList,
    String? currentSearchQuery,
    String? currentStatusFilter,
  }) {
    return KelolaLaporanLoaded(
      laporanList: laporanList ?? this.laporanList,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      currentStatusFilter: currentStatusFilter ?? this.currentStatusFilter,
    );
  }
}

class KelolaLaporanActionSuccess extends KelolaLaporanState {
  final String message;

  const KelolaLaporanActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class KelolaLaporanError extends KelolaLaporanState {
  final String message;

  const KelolaLaporanError({required this.message});

  @override
  List<Object> get props => [message];
}