import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/repository/sos/sos_repository.dart';
import '../sos_email_service.dart';

part 'sos_event.dart';
part 'sos_state.dart';

class SOSBloc extends Bloc<SOSEvent, SOSState> {
  final SOSRepository repository;
  final SOSEmailService emailService;

  SOSBloc(this.repository, this.emailService) : super(SOSInitial()) {
    on<AktifkanSOS>(_onAktifkanSOS);
  }

  Future<void> _onAktifkanSOS(
    AktifkanSOS event, Emitter<SOSState> emit) async {
  emit(SOSLoading());

  final izinDiberikan = await cekDanMintaIzinLokasi();
  if (!izinDiberikan) {
    emit(SOSGagal('Izin lokasi ditolak. Mohon aktifkan izin lokasi.'));
    return;
  }

  try {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await repository.kirimSOS(
      idPengguna: event.idPengguna,
      lat: pos.latitude,
      long: pos.longitude,
      emailTujuan: event.emailTujuan
    );

    // Kirim email/sms/whatsapp di sini sesuai implementasi Anda

    emit(SOSBerhasil());
  } catch (e) {
    emit(SOSGagal('Gagal mengirim SOS: $e'));
  }
}


  Future<bool> cekDanMintaIzinLokasi() async {
  var status = await Permission.location.status;

  if (status.isDenied) {
    status = await Permission.location.request();
  }

  if (status.isPermanentlyDenied) {
    await openAppSettings(); // Buka pengaturan jika ditolak permanen
    return false;
  }

  return status.isGranted;
}

}
