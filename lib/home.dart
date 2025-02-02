import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:validation/login.dart';
import 'package:validation/graph.dart';
import 'package:validation/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic sensorData = [
    {"temp": 0, "humidity": 0, "moisture": 0},
  ];

  Future<void> fetchData() async {
    final response =
    await http.get(Uri.parse('http://127.0.0.1:8000/get-last-sensor-data'));
    if (response.statusCode == 200) {
      setState(() {
        sensorData = json.decode(response.body);
      });
      print("sensorData-->");
      print(json.decode(response.body));
    } else {
      throw Exception('Failed to load sensor data');
    }
  }

  void fetchDataPeriodically() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDataPeriodically();
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToGraph() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GraphPage()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),  // Navigate to the ProfilePage
    );
  }

  Widget _buildSensorDataBox(String label, String value) {
    String moistureMessage = '';
    double? moistureValue;

    if (label == 'Moisture') {
      try {
        moistureValue = double.parse(value.replaceAll('%', ''));
        if (moistureValue < 20) {
          moistureMessage = 'The crop needs water!!!';
        } else if (moistureValue > 60) {
          moistureMessage = "The crop doesn't need water.";
        }
      } catch (e) {
        print('Error parsing moisture value: $e');
      }
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        if (moistureMessage.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              moistureMessage,
              style:
              TextStyle(fontSize: 24, color: moistureValue! < 20 ? Colors.red : Colors.green),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Crop Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  _buildSensorDataBox(
                      'Temperature', '${sensorData[0]['temp']}°C'),
                  _buildSensorDataBox(
                      'Humidity', '${sensorData[0]['humidity']}%'),
                  _buildSensorDataBox(
                      'Moisture', '${sensorData[0]['moisture']}%'),
                ],
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
            icon: Icon(Icons.person),
            label: 'Profile',  // Add the Profile button
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
            _navigateToProfile();  // Handle navigation to the profile page
          } else if (index == 1) {
            _navigateToGraph();
          } else if (index == 2) {
            _logout();
          }
        },
      ),
    );
  }
}
