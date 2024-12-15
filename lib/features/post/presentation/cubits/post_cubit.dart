import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaf/features/post/domain/entities/post.dart';
import 'package:socialmediaf/features/post/presentation/cubits/post_states.dart';
import 'package:socialmediaf/features/post/repository/post_repo.dart';
import 'package:socialmediaf/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;
    try {
      if (imagePath != null) {
        emit(PostsUpLoding());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      } else if (imagePath != null) {
        emit(PostsUpLoding());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes!, post.id);
      }

      final newPost = post.copyWith(imageUrl: imageUrl);
      postRepo.createPost(newPost);
      fetchAllPost();
    } catch (e) {
      throw Exception("failed to create post: $e");
    }
  }

  Future<void> fetchAllPost() async {
    try {
      emit(PostsLoding());
      final posts = await postRepo.fetchAllposts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("faild to fetch posts: $e"));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {}
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostsError("faild to toggle like:$e"));
    }
  }
}
