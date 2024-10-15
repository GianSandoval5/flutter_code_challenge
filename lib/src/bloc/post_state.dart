import 'package:flutter_code_challenge/src/models/post_models.dart';

abstract class PostState {}

class PostsInitial extends PostState {}

class PostsLoading extends PostState {}

class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}

class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}
