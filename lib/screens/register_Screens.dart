import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/user_state.dart';
import 'login_Screens.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _username = "";
  String _password = "";
  String _confirmPassword = "";

  _registerNow() async {
    var isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    bool isRegistered = await Provider.of<UserState>(context, listen: false).registernow(_username, _password);

    if (isRegistered) {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Error"),
          content: Text("Invalid username or password"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text("Ok"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 20),
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: TextFormField(
                    validator: (v) {
                      if (v!.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    onSaved: (v) {
                      _username = v!;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: TextFormField(
                    validator: (v) {
                      if (v!.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _confirmPassword = v;
                      });
                    },
                    onSaved: (v) {
                      _password = v!;
                    },
                    obscureText: true,
                    autocorrect: false,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: TextFormField(
                    validator: (v) {
                      if (_confirmPassword != v) {
                        return 'Passwords do not match';
                      }
                      if (v!.isEmpty) {
                        return 'Confirm your password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    onSaved: (v) {
                      _password = v!;
                    },
                    obscureText: true,
                    autocorrect: false,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _registerNow();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
                  },
                  child: Text(
                    "Already have an account? Login here.",
                    style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
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
