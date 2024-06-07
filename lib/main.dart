import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobileapp/loginPage.dart';
import 'package:mobileapp/openingScreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:mobileapp/classroom.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  CloudinaryContext.cloudinary = Cloudinary.fromCloudName(cloudName: 'dzmagqbeo');
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel of StudySync',
          importance: NotificationImportance.Max,
          defaultPrivacy: NotificationPrivacy.Public,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          locked: true,
          enableVibration: true,
          enableLights: true,
          playSound: true,
        )
      ],
      debug: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Lato',
        appBarTheme:
        const AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
        useMaterial3: true,
      ),
      initialRoute: '/opening',
      routes: {
        '/opening': (context) => OpeningScreen(),
        '/home': (context) => MyHomePage(),
      },
      home: const OpeningScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Classroom {
  int classroomID;
  String className;
  String sectionName;
  int teacherID;

  Classroom({
    required this.classroomID,
    required this.className,
    required this.sectionName,
    required this.teacherID,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      classroomID: json['classroomID'],
      className: json['className'],
      sectionName: json['sectionName'],
      teacherID: json['teacherID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classroomID': classroomID,
      'className': className,
      'sectionName': sectionName,
      'teacherID': teacherID,
    };
  }
}

class ClassroomData {
  Classroom classroom;
  int userID;

  ClassroomData({
    required this.classroom,
    required this.userID,
  });

  factory ClassroomData.fromJson(Map<String, dynamic> json) {
    return ClassroomData(
      classroom: Classroom.fromJson(json['classroom']),
      userID: json['userID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classroom': classroom.toJson(),
      'userID': userID,
    };
  }
}

class Album {
  List<ClassroomData> classrooms;

  Album({
    required this.classrooms,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    var list = json['classrooms'] as List;
    List<ClassroomData> classroomList = list.map((i) => ClassroomData.fromJson(i)).toList();

    return Album(
      classrooms: classroomList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classrooms': classrooms.map((classroomData) => classroomData.toJson()).toList(),
    };
  }
}


Future<Album> fetchAlbum(int userID) async {
  var uri = Uri.https('educserver-production.up.railway.app', '/joined_class_list/$userID');
  final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print('fetchAlbum status code: 200.');
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final List<int> colors = [0xFFFF76CE, 0xFFFDFFC2, 0xFF94FFD8, 0xFFA3D8FF, 0xFFFFB38E];
  final random = Random();
  late Future<Album> futureAlbum;
  late int userID;
  final joinClassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    initializeUser();
  }

  Future<void> initializeUser() async {
    userID = await getUserID();
    setState(() {
      futureAlbum = fetchAlbum(userID);
    });
  }

  Future<void> joinClass(int classroomID, int userID) async {
    var uri = Uri.https('educserver-production.up.railway.app', '/join_class');
    final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "classroomID": classroomID,
          "userID": userID,
        })
    );

    if (response.statusCode == 200) {
      print('joinClass Response: ${response.body}');
      setState(() {
        futureAlbum = fetchAlbum(userID);
      });
    } else {
      // Request failed, handle error here
      print('Failed with status code: ${response.statusCode}');
    }
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

          const Text('You have no classes, add a class.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Add a class'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Join a class'),
                          onTap: () {
                            Navigator.of(context).pop(); // Close the dialog
                            _showJoinClassDialog(context); // Show join class dialog
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Text('Add a class'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF1E213D),
            title: const Text(
              "StudySync",
              style:
              TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
            centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(
                height:
                115, // Adjust height if necessary to fit icon and text appropriately
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
        body: FutureBuilder<Album>(
          future: futureAlbum,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show a loading indicator while fetching data
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              if (snapshot.data!.classrooms.isEmpty) {
                return centerInfo();
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.classrooms.length,
                  itemBuilder: (context, index) {
                    final classroomData = snapshot.data!.classrooms[index];
                    final int colorIndex = random.nextInt(colors.length); // Generate random index
                    return Card(
                      child: ListTile(
                        title: Text(classroomData.classroom.className),
                        subtitle: Text(classroomData.classroom.sectionName),
                        trailing: Text('Class Code: ${classroomData.classroom.classroomID}'),
                        tileColor: Color(colors[colorIndex]),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Class(
                                classroomID: classroomData.classroom.classroomID,
                                classroomName: classroomData.classroom.className,
                              ))
                          );
                        },
                      ),
                    );
                  },
                );
              }
            }
          },
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {// Close the dialog
            _showJoinClassDialog(context);
          },
          label: const Text('Join Class'),
          icon: const Icon(Icons.add),
        )
      ),
    );
  }

  void _showJoinClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Class Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ask your teacher for the class code.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: joinClassController,
                decoration: const InputDecoration(hintText: 'Class Code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  int classroomID = int.parse(joinClassController.text);
                  joinClass(classroomID, userID);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }
}
