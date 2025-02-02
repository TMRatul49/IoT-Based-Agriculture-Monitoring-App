import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:validation/home.dart';
import 'package:validation/graph.dart';
import 'package:validation/login.dart';

class User {
  int id;
  String username;
  String email;
  String role;
  String password;  // Add password field

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.password,  // Add password field
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      password: json['password'],  // Add password field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'password': password,  // Add password field
    };
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();  // Add password controller

  User? currentUser;

  Future<void> _fetchUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/getusers/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          currentUser = User.fromJson(json.decode(response.body));
          usernameController.text = currentUser!.username;
          emailController.text = currentUser!.email;
          roleController.text = currentUser!.role;
          passwordController.text = currentUser!.password;  // Set password field
        });
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (error) {
      print('Error fetching user: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching user'),
      ));
    }
  }

  Future<void> _updateUser() async {
    if (currentUser == null) {
      return;
    }
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/updateusers/?user_id=${currentUser!.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': usernameController.text,
          'email': emailController.text,
          'role': roleController.text,
          'password': passwordController.text,  // Include password field
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User updated successfully'),
          ),
        );
      } else {
        throw Exception('Failed to update user');
      }
    } catch (error) {
      print('Error updating user: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating user'),
      ));
    }
  }

  Future<void> _deleteUser() async {
    if (currentUser == null) {
      return;
    }
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/delusers/?username=${currentUser!.username}'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted successfully'),
          ),
        );
        setState(() {
          currentUser = null;
          userIdController.text = '';
          usernameController.text = '';
          emailController.text = '';
          roleController.text = '';
          passwordController.text = '';  // Clear password field
        });
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (error) {
      print('Error deleting user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('User Profile')),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: userIdController,
                decoration: InputDecoration(labelText: 'Enter User ID: '),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  int userId = int.tryParse(userIdController.text) ?? 0;
                  _fetchUser(userId);
                },
                child: Text('Fetch User Info'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: roleController,
                decoration: InputDecoration(labelText: 'Role'),
              ),
              TextField(
                controller: passwordController,  // Add password field
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Update User'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteUser,
                child: Text('Delete User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Graph',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/graph');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
      ),
    );
  }
}
