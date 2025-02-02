import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:validation/home.dart';
import 'package:validation/main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final String apiUrl = 'http://localhost:8000/login/';

    // Extract the entered identifier and password
    final String identifier = _identifierController.text;
    final String password = _passwordController.text;

    // Check if the entered identifier is an email
    bool isEmail = identifier.contains('@');

    // Construct the query parameters based on whether it's an email or username
    Map<String, String> queryParameters;
    if (isEmail) {
      queryParameters = {'email': identifier, 'password': password};
    } else {
      queryParameters = {'username': identifier, 'password': password};
    }

    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParameters);

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        // Login successful, navigate to the next screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Login failed, show an error message
        final error = jsonDecode(response.body)['detail'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to the server.'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agriculture Monitor App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _login,
                        icon: Icon(Icons.login),
                        label: Text('Login'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  "Don't have an account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/registration');
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // SizedBox(height: 10.0),
                // ElevatedButton.icon(
                //   onPressed: () {
                //     Navigator.pushReplacementNamed(context, '/registration');
                //   },
                //   icon: Icon(Icons.person_add),
                //   label: Text('Sign Up'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}