part of 'sos_bloc.dart';

abstract class SOSState extends Equatable {
  const SOSState();

  @override
  List<Object> get props => [];
}

class SOSInitial extends SOSState {}

class SOSLoading extends SOSState {}

class SOSBerhasil extends SOSState {}

class SOSGagal extends SOSState {
  final String message;

  const SOSGagal(this.message);

  @override
  List<Object> get props => [message];
}


