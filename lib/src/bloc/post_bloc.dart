import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_code_challenge/src/bloc/post_event.dart.dart';
import 'package:flutter_code_challenge/src/models/post_models.dart';
import 'package:http/http.dart' as http;
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostsInitial()) {
    on<LoadPosts>(_onLoadPosts);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    final currentState = state;

    try {
      // Emitimos el estado de carga solo si es la primera vez
      if (event.start == 0) emit(PostsLoading());

      final response = await http.get(Uri.parse(
          'https://jsonplaceholder.typicode.com/posts?_start=${event.start}&_limit=${event.limit}'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final newPosts = data.map((json) => Post.fromJson(json)).toList();

        if (currentState is PostsLoaded) {
          // Agregamos los nuevos posts a los ya existentes
          emit(PostsLoaded(currentState.posts + newPosts));
        } else {
          emit(PostsLoaded(newPosts));
        }
      } else {
        emit(PostsError('Failed to load posts'));
      }
    } catch (e) {
      emit(PostsError('An error occurred: $e'));
    }
  }
}
