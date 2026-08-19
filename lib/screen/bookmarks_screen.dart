import 'package:flutter/material.dart';

class BookmarksScreen extends StatelessWidget{
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks')), 
    body:ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.save),
          title: const Text('Bookmark 1'),
          onTap: () {
            // Handle bookmark tap
          },
        ),
        ListTile(
          leading: const Icon(Icons.bookmark),
          title: const Text('Bookmark 2'),
          onTap: () {
            // Handle bookmark tap
          },
        ),
      ],
      ),
    );
  }
}