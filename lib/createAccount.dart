import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobileapp/loginPage.dart';
import 'package:http/http.dart' as http;

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isTeacher = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signUpRequest(String email, String username, String password, bool isTeacher) async {
    var uri = Uri.https('educserver-production.up.railway.app', '/signup');
    final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "email": email,
          "username": username,
          "password": password,
          "isTeacher": isTeacher,
        })
    );

    if (response.statusCode == 200) {
      // Request successful, handle response here
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoginPage())
      );
      print('Response: $userData');
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
        title: const Text(
          'Create Account',
          style: TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: const Color(0xFF1E213D),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 25, right: 25, top: 70),
                    child: Text(
                      'Username',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Username',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                              BorderSide(width: 1.0, color: Colors.white))),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'Email',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                              BorderSide(width: 1.0, color: Colors.white))),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'Password',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                              BorderSide(width: 1.0, color: Colors.white))),
                    ),
                  ),
                  Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ListTile(
                            title: const Text(
                              'Teacher',
                              style: TextStyle(color: Colors.white),
                            ),
                            leading: Radio<bool>(
                              value: true,
                              groupValue: isTeacher,
                              onChanged: (value) {
                                setState(() {
                                  isTeacher = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: ListTile(
                            title: const Text(
                              'Student',
                              style: TextStyle(color: Colors.white),
                            ),
                            leading: Radio<bool>(
                              value: false,
                              groupValue: isTeacher,
                              onChanged: (value) {
                                setState(() {
                                  isTeacher = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: SizedBox(
                        width: 370,
                        height: 70,
                        child: ElevatedButton(
                            onPressed: () {
                              signUpRequest(_emailController.text, _nameController.text,
                                  _passwordController.text, isTeacher);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFF7DE),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
