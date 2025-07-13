import 'package:equatable/equatable.dart';
import '../../../data/model/user_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthAdmin extends AuthState {
  final UserModel user;

  AuthAdmin({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthNeedsCompletion extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
