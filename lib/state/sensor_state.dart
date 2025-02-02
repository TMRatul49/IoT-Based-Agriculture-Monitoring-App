import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/sensor.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

class SensorState with ChangeNotifier {
  List<Sensor> _sensors = [];
  LocalStorage storage = new LocalStorage('usertoken');
  Future<List<Sensor>> getSensors(int id) async {
    final token = storage.getItem("token");
    var url = Uri.parse(
        'http://192.168.236.23:8000/agri/sensor/$id'); // Replace with your API endpoint for fetching sensors
    try {
      http.Response response =
          await http.get(url, headers: {'Authorization': "token $token"});
      print('API Response: ${response.body}');
      var data = json.decode(response.body) as List;
      print(data);
      List<Sensor> temp = [];
      data.forEach((element) {
        Sensor sensor = Sensor.fromJson(element);
        temp.add(sensor);
      });
      return temp;
    } catch (e) {
      print('Error in getSensors');
      print(e);
      throw "No sensor data is available at this moment"; // You may want to throw the error here to handle it in the UI.
    }
  }

  List<Sensor> get sensors {
    return [..._sensors];
  }

  Sensor singleSensor(int id) {
    return _sensors.firstWhere((element) => element.id == id);
  }
}
