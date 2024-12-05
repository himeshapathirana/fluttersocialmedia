import 'package:socialmediaf/features/post/domain/entities/post.dart';

abstract class PostState {}

class PostsInitial extends PostState {}

class PostsLoding extends PostState {}

class PostsUpLoding extends PostState {}

class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}

class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}
