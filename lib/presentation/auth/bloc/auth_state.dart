import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String nama;
  final String email;

  AuthAuthenticated({required this.nama, required this.email});

  @override
  List<Object?> get props => [nama, email];
}

class AuthAdmin extends AuthState {
  final String nama;
  final String email;

  AuthAdmin({required this.nama, required this.email});

  @override
  List<Object?> get props => [nama, email];
}

class AuthNeedsCompletion extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
