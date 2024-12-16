import 'dart:io';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaf/features/auth/domain/entities/app_user.dart';
import 'package:socialmediaf/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:socialmediaf/features/post/components/post_tile.dart';
import 'package:socialmediaf/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmediaf/features/post/presentation/cubits/post_states.dart';
import 'package:socialmediaf/profile/presentation/components/bio_box.dart';
import 'package:socialmediaf/profile/presentation/components/follow_button.dart';
import 'package:socialmediaf/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmediaf/profile/presentation/cubits/profile_states.dart';
import 'package:socialmediaf/profile/presentation/pages/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  late AppUser? currentUser = authCubit.currentUser;
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
  }

  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // Only toggle the follow status if it's not the same as the current follow status.
    if (isFollowing) {
      profileCubit.toggleFollow(currentUser!.uid, widget.uid); // Unfollow
    } else {
      profileCubit.toggleFollow(currentUser!.uid, widget.uid); // Follow
    }

    // You can update the UI and persist the follow/unfollow status in your state management.
    // For example, you can call setState to update the button immediately.
    setState(() {}); // Trigger re-render after follow/unfollow action.
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;

          return Scaffold(
            appBar: AppBar(
              title: Text(currentUser!.email),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                if (isOwnPost)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: user),
                      ),
                    ),
                    icon: const Icon(Icons.settings),
                  )
              ],
            ),
            body: ListView(
              children: [
                Center(
                  child: Text(
                    user.email,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),

                const SizedBox(height: 25),

                // Handle Profile Image Locally
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pop(); // Close the dialog on tap outside
                          },
                          child: Center(
                            child: Container(
                              height:
                                  250, // Adjust the size for the zoomed image
                              width: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: user.localImageFile != null
                                      ? FileImage(File(
                                          user.localImageFile!)) // Local file
                                      : const AssetImage(
                                              'assets/images/image1.jpg')
                                          as ImageProvider, // Default image
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: user.localImageFile != null
                            ? FileImage(
                                File(user.localImageFile!)) // Local file
                            : const AssetImage('assets/images/image1.jpg')
                                as ImageProvider, // Default image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                if (!isOwnPost)
                  FollowButton(
                    onPressed:
                        followButtonPressed, // Pass the method to toggle follow
                    isFollowing: user.followers.contains(
                        currentUser!.uid), // Check if current user is following
                  ),
                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        "Bio",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                BioBox(text: user.bio),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 25.0),
                  child: Row(
                    children: [
                      Text(
                        "Post",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<PostCubit, PostState>(builder: (context, state) {
                  if (state is PostsLoaded) {
                    final userPosts = state.posts
                        .where((post) => post.userId == widget.uid)
                        .toList();

                    postCount = userPosts.length;
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            itemCount: postCount,
                            physics:
                                const NeverScrollableScrollPhysics(), // Prevents nested scrolling
                            shrinkWrap:
                                true, // Allows ListView to adjust its height to content
                            itemBuilder: (context, index) {
                              final post = userPosts[index];

                              return PostTile(
                                post: post,
                                onDeletePressed: () => context
                                    .read<PostCubit>()
                                    .deletePost(post.id),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  } else if (state is PostsLoding) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const Center(
                      child: Text("No posts.."),
                    );
                  }
                })
              ],
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Center(
            child: Text("No profile found!"),
          );
        }
      },
    );
  }

  /*@override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        print("Current State: $state");

        if (state is ProfileLoaded) {
          final user = state.profileUser;

          return Scaffold(
            appBar: AppBar(
              title: Text(currentUser!.email),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: user),
                      )),
                  icon: const Icon(Icons.settings),
                )
              ],
            ),
            body: Column(
              children: [
                Text(
                  user.email,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),

                const SizedBox(height: 25),
                // Add more UI elements for bio, profile image, etc.
                /*Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12)),
                  height: 120,
                  width: 120,
                  padding: const EdgeInsets.all(25),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 72,
                      //color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),*/

                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 72,
                    color: Colors.black26,
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        "Bio",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                BioBox(text: user.bio),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 25.0),
                  child: Row(
                    children: [
                      Text(
                        "Post",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Center(
            child: Text("No profile found!"),
          );
        }
      },
    );
  }*/
}
