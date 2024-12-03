import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaf/features/auth/data/firebase_auth_repo.dart';
import 'package:socialmediaf/features/auth/home/presentation/pages/home_page.dart';
import 'package:socialmediaf/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:socialmediaf/features/auth/presentation/cubit/auth_states.dart';
import 'package:socialmediaf/features/auth/presentation/pages/auth_page.dart';
import 'package:socialmediaf/features/storage/data/firebase_storage_repo.dart';
import 'package:socialmediaf/features/storage/domain/storage_repo.dart';
import 'package:socialmediaf/profile/data/firebase_profile_repo.dart';
import 'package:socialmediaf/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmediaf/theme/light_model.dart';

class MyApp extends StatelessWidget {
  final firebaseAuthRepo = FirebaseAuthRepo();
  final firebasePorfileRepo = FirebaseProfileRepo();
  final firebaseStorageRepo = FirebaseStorageRepo();

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
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
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
    );
  }
}
