import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaf/profile/domain/repository/profile_repo.dart';
import 'package:socialmediaf/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  // Fetch user profile
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      print("Fetching user profile for UID: $uid");
      final user = await profileRepo.fetchUserProfile(uid);
      print("Fetched user: $user");

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found!"));
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      emit(ProfileError(e.toString()));
    }
  }

  // Update profile or profile picture
  Future<void> updateProfile({
    required String uid,
    String? newBio,
  }) async {
    emit(ProfileLoading());

    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("failed to fetch user"));
        return;
      }

      //updatedprofile
      final updatedProfile =
          currentUser.copyWith(newBio: newBio ?? currentUser.bio);

      await profileRepo.updateProfile(updatedProfile);
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("error updating profile: $e"));
    }
  }
}
