import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaf/features/auth/home/presentation/pages/components/drawer.dart';
import 'package:socialmediaf/features/auth/home/presentation/pages/components/post_tile.dart';
import 'package:socialmediaf/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmediaf/features/post/presentation/cubits/post_states.dart';
import 'package:socialmediaf/features/post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();
  }

  void fetchAllPost() {
    postCubit.fetchAllPost();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadPostPage(),
                )),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsLoding && state is PostsUpLoding) {
            // Show loading indicator
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(
                child: Text("No posts available"),
              );
            }

            // Display the list of posts
            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];
                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              },
            );
          } else if (state is PostsError) {
            // Handle unexpected states
            return const Center(
              child: Text("Something went wrong!"),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      drawer: const MyDrawer(),
    );
  }
}
