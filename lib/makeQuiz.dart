import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizPage extends StatefulWidget {
  int classroomID;

  QuizPage({
    required this.classroomID,
    super.key,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class Content {
  int quizID;
  String quizTitle;
  int classroomID;

  Content({
    required this.quizID,
    required this.quizTitle,
    required this.classroomID,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      quizID: json['quizID'],
      quizTitle: json['quizTitle'],
      classroomID: json['classroomID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizID': quizID,
      'quizTitle': quizTitle,
      'classroomID': classroomID,
    };
  }
}

class Album {
  List<Content> quizzes;

  Album({
    required this.quizzes,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    var list = json['quizzes'] as List;
    List<Content> contentList = list.map((i) => Content.fromJson(i)).toList();

    return Album(
      quizzes: contentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizzes': quizzes.map((quizzes) => quizzes.toJson()).toList(),
    };
  }
}

Future<Album> fetchAlbum(int classroomID) async {
  var uri = Uri.https('educserver-production.up.railway.app', '/get_quiz/$classroomID');
  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class _QuizPageState extends State<QuizPage> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum(widget.classroomID);
  }

  Future<void> refreshQuizList() async {
    setState(() {
      futureAlbum = fetchAlbum(widget.classroomID);
    });
  }

  Widget displayContents() {
    return FutureBuilder<Album>(
      future: futureAlbum,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading indicator while fetching data
        } else {
          if (snapshot.data!.quizzes.isEmpty) {
            return centerInfo();
          } else {
            return contentsAndButton(snapshot);
          }
        }
      },
    );
  }

  Widget contentsAndButton(snapshot) {
    return Column(
      children: [
        Expanded(
            flex: 8,
            child: ListView.builder(
              itemCount: snapshot.data!.quizzes.length,
              itemBuilder: (context, index) {
                final quiz = snapshot.data!.quizzes[index];
                return Card(
                  child: ListTile(
                    title: Text(quiz.quizTitle),
                    tileColor: const Color(0xFFFFDA78),
                    onTap: () {
                    },
                  ),
                );
              },
            )
        ),
      ],
    );
  }

  Widget centerInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          Image.asset(
            'assets/studysync1.png',
            scale: 8,
          ),

          const Text('You have no quizzes.',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return displayContents();
  }
}

