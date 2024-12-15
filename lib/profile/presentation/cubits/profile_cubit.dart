import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaf/features/storage/domain/storage_repo.dart';
import 'package:socialmediaf/profile/domain/entities/profile_users.dart';
import 'package:socialmediaf/profile/domain/repository/profile_repo.dart';
import 'package:socialmediaf/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo})
      : super(ProfileInitial());

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

  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  // Update profile or profile picture
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());

    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("failed to fetch user"));
        return;
      }

      //update profile pic
      String? imageDownloadUrl;

      if (imageWebBytes != null || imageMobilePath != null) {
        if (imageMobilePath != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
        } else if (imageWebBytes != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }
        if (imageDownloadUrl == null) {
          emit(ProfileError("Faild to upload image"));
          return;
        }
      }

      //updatedprofile
      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      await profileRepo.updateProfile(updatedProfile);
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("error updating profile: $e"));
    }
  }
}
