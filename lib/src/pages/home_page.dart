// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_code_challenge/src/imports.dart';
import 'package:flutter_code_challenge/src/utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final int _postLimit = 10;
  bool _isLoading = false;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(LoadPosts(start: 0, limit: _postLimit));
    _scrollController.addListener(_onScroll);
    tabController = TabController(length: 2, vsync: this);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchMorePosts();
    }
  }

  void _fetchMorePosts() {
    setState(() {
      _isLoading = true;
    });

    final postBloc = context.read<PostBloc>();
    if (postBloc.state is PostsLoaded) {
      final currentPosts = (postBloc.state as PostsLoaded).posts;
      postBloc.add(LoadPosts(start: currentPosts.length, limit: _postLimit));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 100.0,
              backgroundColor: AppColors.blueColors,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
              ),
              title: Center(
                child: Text(
                  "Blog",
                  style: TextStyle(
                    fontFamily: "CS",
                    fontSize: 25,
                    color: AppColors.ligthColors,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  tabAlignment: TabAlignment.center,
                  physics: const BouncingScrollPhysics(),
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 30),
                  indicatorColor: AppColors.darkColors,
                  labelColor: AppColors.darkColors,
                  unselectedLabelColor: AppColors.darkColors,
                  controller: tabController,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Vacío'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: [
            _buildPostList(),
            const Center(child: Text('No hay contenido aquí.')),
          ],
        ),
      ),
    );
  }

  Widget _buildPostList() {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostsLoaded) {
          setState(() {
            _isLoading = false; // Reset _isLoading when posts are loaded
          });
        }
      },
      child: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsLoaded) {
            return ListView.builder(
              itemCount: state.posts.length + 1,
              itemBuilder: (context, index) {
                if (index == state.posts.length) {
                  return _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: LinearProgressIndicator(),
                        )
                      : const SizedBox.shrink();
                }

                final Post post = state.posts[index];
                return CardPostWidget(post: post);
              },
            );
          } else if (state is PostsError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('No hay posts'));
          }
        },
      ),
    );
  }
}

class CardPostWidget extends StatelessWidget {
  const CardPostWidget({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 8.0),
                decoration: BoxDecoration(
                  color: AppColors.purpleColors,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    "Community",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.ligthColors,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(post.body),
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text(
                      'Ver más',
                      style: TextStyle(color: AppColors.blueColors),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.blueColors,
                      size: 25,
                    ),
                  ],
                ),
              ),
              Image.asset('assets/logo.png'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.ligthColors,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
