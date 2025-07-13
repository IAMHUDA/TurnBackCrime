// ---------------------------
// Profile States
// ---------------------------
part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {}

class ProfileUpdateFailure extends ProfileState {
  final String message;
  
  const ProfileUpdateFailure(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  
  const ProfileLoaded(this.user);
  
  @override
  List<Object?> get props => [user];
}

class ProfileLoading extends ProfileState {}