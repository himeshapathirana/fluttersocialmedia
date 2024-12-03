import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaf/features/auth/domain/entities/app_user.dart';
import 'package:socialmediaf/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:socialmediaf/profile/presentation/components/bio_box.dart';
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

  @override
  void initState() {
    super.initState();
    print('Fetching profile for UID: ${widget.uid}');
    profileCubit.fetchUserProfile(widget.uid);
  }

  @override
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
                Container(
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
  }
}
