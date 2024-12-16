import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmediaf/profile/domain/entities/profile_users.dart';
import 'package:socialmediaf/profile/domain/repository/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final userDoc =
          await firebaseFirestore.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        print('Fetched user data: $userData');
        if (userData != null) {
          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);

          return ProfileUser(
            uid: uid,
            email: userData['email'],
            name: userData['name'],
            bio: userData['bio'] ?? '',
            profileImageUrl: userData['profileImageUrl'].toString(),
            followers: followers,
            following: following,
          );
        }
      }
      print('User document does not exist or is empty');
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update({
        'bio': updatedProfile.bio,
        'profileImageUrl': updatedProfile.profileImageUrl,
      });
    } catch (e) {
      print("Error updating profile: $e");
      throw Exception("Error updating profile: $e");
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      final currentUserDoc =
          await firebaseFirestore.collection('users').doc(currentUid).get();
      final targetUserDoc =
          await firebaseFirestore.collection('users').doc(targetUid).get();
      if (currentUserDoc.exists && targetUserDoc.exists) {
        final currentUserData = currentUserDoc.data();
        final targetUserData = targetUserDoc.data();

        if (currentUserData != null && targetUserData != null) {
          final List<String> currentFollowing =
              List<String>.from(currentUserData['following'] ?? []);

          if (currentFollowing.contains(targetUid)) {
            await firebaseFirestore.collection('user').doc(currentUid).update({
              'following': FieldValue.arrayRemove([targetUid])
            });
            await firebaseFirestore.collection('user').doc(targetUid).update({
              'following': FieldValue.arrayRemove([currentUid])
            });
          } else {
            await firebaseFirestore.collection('user').doc(currentUid).update({
              'following': FieldValue.arrayUnion([targetUid])
            });
            await firebaseFirestore.collection('user').doc(targetUid).update({
              'following': FieldValue.arrayUnion([currentUid])
            });
          }
        }
      }
    } catch (e) {}
  }
}
