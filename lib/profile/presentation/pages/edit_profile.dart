import 'dart:io'; // For handling file operations in mobile applications.
import 'dart:typed_data'; // For using Uint8List to store image data.
// For loading and caching network images efficiently.
import 'package:flutter/foundation.dart'
    show kIsWeb; // For platform checks to distinguish between web and mobile.
import 'package:file_picker/file_picker.dart'; // For allowing file picking from the device.
import 'package:flutter/material.dart'; // Core Flutter framework.
import 'package:flutter_bloc/flutter_bloc.dart'; // For managing state with Bloc.
import 'package:socialmediaf/features/auth/presentation/components/my_text_field.dart'; // Custom text field widget.
import 'package:socialmediaf/profile/domain/entities/profile_users.dart'; // Profile user entity class.
import 'package:socialmediaf/profile/presentation/cubits/profile_cubit.dart'; // Cubit for managing profile-related logic.
import 'package:socialmediaf/profile/presentation/cubits/profile_states.dart'; // States for ProfileCubit.

class EditProfilePage extends StatefulWidget {
  final ProfileUser user; // User data to edit.

  const EditProfilePage({
    super.key,
    required this.user, // Requires a user object as a parameter.
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  PlatformFile? imagePickedFile; // Holds the file picked by the user.
  Uint8List?
      webImage; // Stores the picked image in web-specific Uint8List format.

  late TextEditingController bioTextController;

  @override
  void initState() {
    super.initState();
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

    // Firebase backend logic is commented out for now.
    /*
    if (imagePickedFile != null) {
      // Example of uploading the image to Firebase Storage.
      final storageRef = FirebaseStorage.instance.ref();
      final uploadTask = storageRef.child('profileImages/$uid.jpg').putFile(File(imageMobilePath!));
      final imageUrl = await (await uploadTask).ref.getDownloadURL();

      // Update the user's profile in Firestore.
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImageUrl': imageUrl,
        'bio': newBio ?? widget.user.bio,
      });
    }
    */

    // Temporary logic to update profile locally for the frontend-only mode.
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
              child: (imagePickedFile != null)
                  ? (kIsWeb
                      ? Image.memory(
                          webImage!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(imagePickedFile!.path!),
                          fit: BoxFit.cover,
                        ))
                  : const Icon(
                      Icons.person,
                      size: 72,
                      color: Colors.grey,
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
