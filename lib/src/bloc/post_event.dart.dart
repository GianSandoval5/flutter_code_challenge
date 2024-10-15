abstract class PostEvent {}

class LoadPosts extends PostEvent {
  final int start;
  final int limit;

  LoadPosts({required this.start, required this.limit});
}
