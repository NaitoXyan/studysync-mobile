import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

late final userData;

Future<int> getUserID() async {
  final prefs = await SharedPreferences.getInstance();

  print('get userID attempting');
  return prefs.getInt('userID')!;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> saveUserID(int userID) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('userID', userID);
    print('save userID successful');
  }

  Future<void> loginRequest(String username, String password) async {
    var uri = Uri.https('educserver-production.up.railway.app', '/login');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "username": username,
        "password": password,
      })
    );

    if (response.statusCode == 200) {
      // Request successful, handle response here
      userData = jsonDecode(response.body);
      saveUserID(userData['user']['id']);
      if (mounted) {
        Navigator.pushNamed(context, '/home');
      }
      print('Response: $userData');
      print(userData['user']['id']);
    } else {
      // Request failed, handle error here
      print('Failed with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF1E213D),
          title: const Text('Log In',
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold
            ),
          )
      ),
      backgroundColor: const Color(0xFF1E213D),
      body: Form(
        key: _formKey,
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(left: 25, right: 25, top: 70),
                  child: Text(
                    'Username',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                ),

                Padding(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Username',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                            ),
                            borderSide: BorderSide(
                                width: 1.0,
                                color: Colors.white
                            )
                        )
                    ),
                  ),
                ),

                const Padding(padding: EdgeInsets.only(left: 25, right: 25),
                  child: Text(
                    'Password',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                ),

                Padding(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 55),
                  child: TextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                            ),
                            borderSide: BorderSide(
                                width: 1.0,
                                color: Colors.white
                            )
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: SizedBox(
                      width: 370,
                      height: 70,
                      child: GestureDetector(
                        onTap: () {

                        },
                        child: ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                loginRequest(_usernameController.text, _passwordController.text);
                              });

                              // if (navigate == true) {
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(builder: (context) => const MyHomePage())
                              //   );
                              // }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFF7DE),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)
                                )
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black
                              ),
                            )
                        ),
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}


