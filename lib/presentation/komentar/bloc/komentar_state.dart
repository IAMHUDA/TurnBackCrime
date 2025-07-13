part of 'komentar_bloc.dart';

abstract class KomentarState extends Equatable {
  const KomentarState();

  @override
  List<Object> get props => [];
}

class KomentarInitial extends KomentarState {}

class KomentarLoading extends KomentarState {}

class KomentarLoaded extends KomentarState {
  final KomentarResponse response;

  const KomentarLoaded(this.response);

  @override
  List<Object> get props => [response];
}

class KomentarError extends KomentarState {
  final String message;

  const KomentarError(this.message);

  @override
  List<Object> get props => [message];
}