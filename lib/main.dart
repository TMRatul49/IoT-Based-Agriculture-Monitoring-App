import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:validation/login.dart';
import 'package:validation/home.dart';
import 'package:validation/graph.dart';
import 'package:validation/profile.dart';

void main() {
  runApp(MaterialApp(
    title: 'Agriculture Monitor App',
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginScreen(),
      '/registration': (context) => OTPGenerator(),
      '/home': (context) => HomePage(),
      '/graph': (context) => GraphPage(),
      '/profile': (context) => ProfilePage(),
    },
  ));
}

class User {
  final String username;
  final String password;
  final String email;
  final String role;

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'role': role,
    };
  }
}

class OTPGenerator extends StatefulWidget {
  @override
  _OTPGeneratorState createState() => _OTPGeneratorState();
}

class _OTPGeneratorState extends State<OTPGenerator> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'Farmer'; // Default selected role
  final TextEditingController _otpController = TextEditingController();
  bool _isOTPGenerated = false;
  String _otp = '';
  String _verificationMessage = '';

  Future<void> _createUser() async {
    final user = User(
      username: _usernameController.text,
      password: _passwordController.text,
      email: _emailController.text,
      role: _selectedRole, // Use selected role
    );

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/users/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String message = responseData['msg'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create user')),
      );
    }
  }

  Future<void> _generateOTP() async {
    final String apiUrl = 'http://localhost:8000/generate_otp/';
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: {'email': _emailController.text});

    final response = await http.post(
      uri,
    );

    if (response.statusCode == 200) {
      print('OTP generated successfully');
      _showOTPDialog();
    } else {
      print('Failed to generate OTP: ${response.body}');
    }
  }

  Future<void> _validateOTP() async {
    final String apiUrl = 'http://localhost:8000/validate_otp/';
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: {
      'email': _emailController.text,
      'entered_otp': _otpController.text,
    });

    final response = await http.post(
      uri,
    );

    if (response.statusCode == 200) {
      setState(() {
        _verificationMessage = 'OTP verified successfully';
      });
    } else {
      setState(() {
        _verificationMessage = 'Failed to verify OTP';
      });
    }
  }

  Future<void> _showOTPDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Enter OTP',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'OTP'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _validateOTP();
                _createUser();
                Navigator.of(context).pop();
              },
              child: Text('Verify'),
            ),
          ],
        );
      },
    );
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
                  'Sign up',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    alignLabelWithHint: true,
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    alignLabelWithHint: true,
                  ),
                ),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    alignLabelWithHint: true,
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  items: ['Farmer', 'Caretaker', 'Farm Owner']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Role',
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    onPressed: _generateOTP,
                    icon: Icon(Icons.person_add),
                    label: Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Already have an account?',
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
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                if (_isOTPGenerated)
                  Text(
                    'OTP Generated: $_otp',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 16.0),
                Text(
                  _verificationMessage,
                  style: TextStyle(
                    color: _verificationMessage.contains('successfully') ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}