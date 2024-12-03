import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaf/features/auth/presentation/components/my_text_field.dart';
import 'package:socialmediaf/profile/domain/entities/profile_users.dart';
import 'package:socialmediaf/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmediaf/profile/presentation/cubits/profile_states.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;

  late TextEditingController bioTextController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the current bio
    bioTextController = TextEditingController(text: widget.user.bio);
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  void uploadProfile() async {
    final profileCubit = context.read<ProfileCubit>();
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;

    final String uid = widget.user.uid;

    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Uploading..."),
                ],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Failed to update profile: ${state.message}")),
          );
        }
      },
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: uploadProfile,
            icon: const Icon(Icons.upload),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.hardEdge,
              child: (!kIsWeb && imagePickedFile != null)
                  ? Image.file(
                      File(imagePickedFile!.path!),
                      fit: BoxFit.cover,
                    )
                  : (kIsWeb && webImage != null)
                      ? Image.memory(webImage!)
                      : CachedNetworkImage(
                          imageUrl: widget.user.profileImageUrl,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 72,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          imageBuilder: (context, imageProvider) => Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: const Text("Pick Image"),
            ),
          ),
          const Text("Edit your bio"),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextField(
              controller: bioTextController,
              hintText: "Enter your bio...",
              obscureText: false,
            ),
          ),
        ],
      ),
    );
  }
}
