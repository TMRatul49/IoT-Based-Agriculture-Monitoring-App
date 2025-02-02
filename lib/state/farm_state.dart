import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/farm.dart';
import 'package:http/http.dart' as http;

class FarmState with ChangeNotifier {
  LocalStorage storage = new LocalStorage('usertoken');
  List<Farm> _farms = [];
  var id; // Define id as an integer
  Future<bool> getFarms() async {
    id = await getTokena(storage);
    // var url = Uri.parse('http://10.0.2.2:8000/agri/farm/$id');
    var url = Uri.parse('http://192.168.236.23:8000/agri/farm/$id');
    print(id);
    var token = storage.getItem('token');
    try {
      http.Response response =
          await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List<dynamic>; // Parse as List
        print(data);
        List<Farm> temp = data.map((element) {
          return Farm.fromJson(element);
        }).toList();
        _farms = temp;
        return true;
      } else {
        print("Error in getFarms: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error in getFarms: $e");
      return false;
    }
  }

  List<Farm> get farms {
    return [..._farms];
  }

  Farm singleFarm(int id) {
    return _farms.firstWhere((element) => element.id == id);
  }
}

Future<int> getTokena(LocalStorage storage) async {
  // var url = Uri.parse('http://10.0.2.2:8000/agri/get_user_id/');
  var url = Uri.parse('http://192.168.236.23:8000/agri/get_user_id/');
  var token =
      await storage.getItem('token'); // Assuming you have a 'token' stored
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userId = data['user_id'];
      // print(userId);
      return userId; // Return the user ID as an integer
    } else {
      print("Error in getTokena: ${response.statusCode}");
      return 0;
    }
  } catch (e) {
    print("Error in getTokena: $e");
    return 0;
  }
}
