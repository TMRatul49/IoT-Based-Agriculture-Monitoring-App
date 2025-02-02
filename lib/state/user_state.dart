import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

class UserState with ChangeNotifier {
  LocalStorage storage = new LocalStorage('usertoken');

  Future<bool> loginNow(String uname, String passw) async {
    Uri url = Uri.parse(
        'http://192.168.236.23:8000/agri/login/'); // Convert the URL string to Uri
    try {
      http.Response response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({"username": uname, "password": passw}));
      var data = json.decode(response.body) as Map;

      if (data.containsKey("token")) {
        storage.setItem("token", data['token']);
        print(storage.getItem('token'));
        return true;
      }
      return false;
    } catch (e) {
      print("e loginNow");
      print(e);
      return false;
    }
  }

  Future<bool> registernow(String uname, String passw) async {
    Uri url = Uri.parse(
        'http://192.168.236.23:8000/agri/register/'); // Convert the URL string to Uri
    try {
      http.Response response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({"username": uname, "password": passw}));
      var data = json.decode(response.body) as Map;
      print(data);
      if (data["error"] == false) {
        return true;
      }
      return false;
    } catch (e) {
      print("e registernow");
      print(e);
      return false;
    }
  }
}
