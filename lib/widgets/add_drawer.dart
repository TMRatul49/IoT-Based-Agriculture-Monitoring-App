import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../screens/login_Screens.dart';

class AppDrower extends StatefulWidget {
  @override
  _AppDrowerState createState() => _AppDrowerState();
}

class _AppDrowerState extends State<AppDrower> {
  LocalStorage storage = new LocalStorage('usertoken');

  void _logoutnew() async {
    await storage.clear();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text("Welcome"),
            automaticallyImplyLeading: false,
          ),
          Spacer(),
          ListTile(
            onTap: () {
              _logoutnew();
            },
            trailing: Icon(
              Icons.logout,
              color: Colors.green,
            ),
            title: Text("Logout"),
          ),
        ],
      ),
    );
  }
}