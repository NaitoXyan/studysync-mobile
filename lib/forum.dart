import 'package:flutter/material.dart';

class ForumPostScreen extends StatefulWidget {
  const ForumPostScreen({Key? key}) : super(key: key);

  @override
  State<ForumPostScreen> createState() => _ForumPostScreenState();
}

class _ForumPostScreenState extends State<ForumPostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  // Add logic to display user icon
                  child: Icon(Icons.person),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add logic to post the forum message
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}