import 'package:socialmediaf/features/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllposts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostsByUserId(String userId);
}
