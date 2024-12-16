import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaf/features/auth/data/firebase_auth_repo.dart';
import 'package:socialmediaf/features/auth/home/presentation/pages/home_page.dart';
import 'package:socialmediaf/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:socialmediaf/features/auth/presentation/cubit/auth_states.dart';
import 'package:socialmediaf/features/auth/presentation/pages/auth_page.dart';
import 'package:socialmediaf/features/post/data/firebase_post_repo.dart';
import 'package:socialmediaf/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmediaf/features/storage/data/firebase_storage_repo.dart';

import 'package:socialmediaf/profile/data/firebase_profile_repo.dart';
import 'package:socialmediaf/profile/presentation/cubits/profile_cubit.dart';

import 'package:socialmediaf/theme/theme_cubit.dart';

class MyApp extends StatelessWidget {
  final firebaseAuthRepo = FirebaseAuthRepo();
  final firebasePorfileRepo = FirebaseProfileRepo();
  final firebaseStorageRepo = FirebaseStorageRepo();
  final firebasePostRepo = FirebasePostRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebasePorfileRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebasePorfileRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: firebasePostRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, currentTheme) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: currentTheme,
          home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, authState) {
              print(authState);
              // Replace with proper logging if needed

              if (authState is Unauthenticated) {
                return const AuthPage();
              }
              if (authState is Authenticated) {
                return const HomePage();
              } else {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
            listener: (context, state) {
              if (state is AuthErrors) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ),
      ),
    );
  }
}
