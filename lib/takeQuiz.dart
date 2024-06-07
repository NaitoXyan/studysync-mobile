import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'loginPage.dart';

class Score {
  int score;

  Score({
    required this.score,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      score: json['score'],
    );
  }
}

Future<int?> fetchScore(int quizID) async {
  var uri = Uri.https('educserver-production.up.railway.app', '/get_score/$quizID');
  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    try {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['score'];
    } catch (e) {
      throw Exception('Failed to parse score: $e');
    }
  } else if (response.statusCode == 404) {
    // If the score is not found, return null
    return null;
  } else {
    throw Exception('Failed to load score. Status code: ${response.statusCode}');
  }
}

class QuizPage extends StatefulWidget {
  final int classroomID;

  QuizPage({
    required this.classroomID,
    Key? key,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class Quiz {
  int quizID;
  String quizTitle;
  int classroomID;

  Quiz({
    required this.quizID,
    required this.quizTitle,
    required this.classroomID,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      quizID: json['quizID'],
      quizTitle: json['quizTitle'],
      classroomID: json['classroomID'],
    );
  }
}

Future<List<Quiz>> fetchQuizzes(int classroomID) async {
  var uri = Uri.https('educserver-production.up.railway.app', '/get_quiz/$classroomID');
  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    try {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      var quizzes = data['quizzes'] as List;
      return quizzes.map((q) => Quiz.fromJson(q)).toList();
    } catch (e) {
      throw Exception('Failed to parse quizzes: $e');
    }
  } else {
    throw Exception('Failed to load quizzes. Status code: ${response.statusCode}');
  }
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<Quiz>> futureQuizzes;

  @override
  void initState() {
    super.initState();
    futureQuizzes = fetchQuizzes(widget.classroomID);
  }

  Widget centerInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          Image.asset(
            'assets/studysync1.png',
            scale: 12,
          ),

          const Text('You have no quizzes.',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600
            ),
          ),

          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  displayScore(int quizIDD) async {
    var quizScore = await fetchScore(quizIDD);
    print (quizScore);
    return quizScore;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Quiz>>(
        future: futureQuizzes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load quizzes: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return centerInfo();
          } else {
            var quizzes = snapshot.data!;
            return ListView.builder(
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                var quizScore = displayScore(quiz.quizID);
                return Card(
                  child: ListTile(
                    title: Text(quiz.quizTitle),
                    tileColor: const Color(0xFFFFDA78),
                    trailing:  FutureBuilder<int?>(
                      future: fetchScore(quiz.quizID),
                      builder: (context, scoreSnapshot) {
                        if (scoreSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (scoreSnapshot.hasError) {
                          return const Text('Not taken yet');
                        } else if (!scoreSnapshot.hasData || scoreSnapshot.data == null) {
                          return const Text('Not taken yet');
                        } else {
                          return Text('Score: ${scoreSnapshot.data.toString()}');
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakeQuizPage(quizID: quiz.quizID),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Question {
  String question;
  List<String> options;
  int correctOption;
  int quizID;

  Question({
    required this.question,
    required this.options,
    required this.correctOption,
    required this.quizID,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOption: json['correctOption'],
      quizID: json['quizID'],
    );
  }
}

Future<List<Question>> fetchQuestions(int quizID) async {
  var uri = Uri.https('educserver-production.up.railway.app', '/get_questions/$quizID');
  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    try {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      var questions = data['questions'] as List;
      print(questions);
      return questions.map((q) => Question.fromJson(q)).toList();
    } catch (e) {
      throw Exception('Failed to parse questions: $e');
    }
  } else {
    throw Exception('Failed to load questions. Status code: ${response.statusCode}');
  }
}

class TakeQuizPage extends StatefulWidget {
  final int quizID;

  TakeQuizPage({required this.quizID, Key? key}) : super(key: key);

  @override
  _TakeQuizPageState createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage> {
  late Future<List<Question>> futureQuestions;
  late List<Question> questions;
  int currentQuestionIndex = 0;
  int score = 0;
  bool showScore = false;

  @override
  void initState() {
    super.initState();
    futureQuestions = fetchQuestions(widget.quizID);
  }

  void _answerQuestion(int selectedOption) {
    if (selectedOption == questions[currentQuestionIndex].correctOption) {
      score++;
    }
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        showScore = true;
      }
    });
  }

  void _resetQuiz() async {
    var userID = await getUserID();
    postScoreRequest(score, userID, widget.quizID);
    // setState(() {
    //   currentQuestionIndex = 0;
    //   score = 0;
    //   showScore = false;
    // });
  }

  Future<void> postScoreRequest(int score, int userID, int quizID) async {
    var uri = Uri.https('educserver-production.up.railway.app', '/post_score');
    final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          "score": score,
          "userID": userID,
          "quizID": quizID,
        })
    );

    if (response.statusCode == 200) {
      // Request successful, handle response here
      print('Post score successful');
      Navigator.pop(context);
    } else {
      // Request failed, handle error here
      print('Failed with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Quiz'),
        backgroundColor: Colors.lightGreen,
      ),
      body: FutureBuilder<List<Question>>(
        future: futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load questions: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions available.'));
          } else {
            questions = snapshot.data!;
            return showScore
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Your score is $score/${questions.length}',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ElevatedButton(
                          onPressed: _resetQuiz,
                          child: const Text('Exit',
                              style: TextStyle(fontSize: 25)
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.width * 0.2),
                        Text(
                          questions[currentQuestionIndex].question,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 20, width: MediaQuery.of(context).size.width * 8),
                        ...questions[currentQuestionIndex].options
                            .asMap()
                            .entries
                            .map((option) => Card(
                          child: ListTile(
                            onTap: () => _answerQuestion(option.key),
                            leading: Text(option.value,
                                style: const TextStyle(fontSize: 22)
                            ),
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                );
          }
        },
      ),
    );
  }
}
