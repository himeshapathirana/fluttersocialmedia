import 'package:socialmediaf/profile/domain/entities/profile_users.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchUserProfile(String uid);
  Future<void> updateProfile(ProfileUser updateProfile);
  Future<void> toggleFollow(String currentUid, String targetUid);
}
