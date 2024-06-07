import 'package:flutter/material.dart';
import 'package:mobileapp/courseContent.dart';
import 'takeQuiz.dart';
import 'courseContent.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class Class extends StatefulWidget {
  int classroomID;
  String classroomName;

  Class({
    required this.classroomID,
    required this.classroomName,
    super.key
  });

  @override
  State<Class> createState() => _ClassState();
}

class _ClassState extends State<Class> {
  int _currentIndex = 0; // To track the index of the currently selected tab

  TabBar get _tabBar => TabBar(
    labelColor: Colors.amber,
    unselectedLabelColor: Colors.white,
    indicatorColor: Colors.amber,
    indicatorSize: TabBarIndicatorSize.tab,
    tabs: const [
      Tab(text: 'Course Contents'),
      Tab(text: 'Quizzes'),
    ],
    onTap: (index) {
      setState(() {
        _currentIndex = index; // Update the current index when a tab is tapped
      });
    },
  );

  Widget _buildCourseContentsTab() {
    return PDFUploadScreen(classroomID: widget.classroomID);
  }

  Widget _buildQuizzesTab() {
    return QuizPage(classroomID: widget.classroomID,);
  }

  Widget _buildForumTab() {
    return  Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Add logic to post the forum message
                    },
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E213D),
          title: Text(
            widget.classroomName,
            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: Material(
              color: const Color(0xFF212761),
              child: _tabBar,
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(
                height: 115, // Adjust height if necessary to fit icon and text appropriately
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF1E213D), // Same as AppBar background color
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.menu, color: Colors.white), // Drawer icon
                      SizedBox(width: 10), // Space between icon and text
                    ],
                  ),
                ),
              ),
              const ListTile(
                title: Text('Welcome to StudySync'),
              ),
              ListTile(
                title: const Text('Log out'),
                onTap: () {
                  Navigator.popUntil(context, ModalRoute.withName('/opening'));
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCourseContentsTab(),
            _buildQuizzesTab(),
          ],
        ),
      ),
    );
  }
}
