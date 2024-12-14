import 'package:flutter/material.dart';
import 'package:socialmediaf/features/auth/home/presentation/pages/components/drawer.dart';
import 'package:socialmediaf/features/post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      drawer: const MyDrawer(),
    );
  }
}
