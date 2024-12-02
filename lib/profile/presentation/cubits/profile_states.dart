import 'package:socialmediaf/profile/domain/entities/profile_users.dart';

abstract class ProfileState {}

//install
class ProfileInitial extends ProfileState {}

//loading
class ProfileLoading extends ProfileState {}

//loaded
class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;
  ProfileLoaded(this.profileUser);
}

//error
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
