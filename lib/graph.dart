import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:validation/login.dart';
import 'package:validation/profile.dart';
import 'package:validation/home.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  List<dynamic> sensorData = [];

  Future<void> fetchData() async {
    final response =
    await http.get(Uri.parse('http://127.0.0.1:8000/get-sensor-data'));
    if (response.statusCode == 200) {
      setState(() {
        sensorData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load sensor data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List<LineChartBarData> _buildLineChartBarData(
      List<dynamic> data, String valueKey) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length && i < 5; i++) {
      spots.add(FlSpot(i.toDouble(), data[i][valueKey].toDouble()));
    }

    return [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Graph Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Charts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: LineChart(
                LineChartData(
                  lineBarsData:
                  _buildLineChartBarData(sensorData, 'temp'),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(text: 'Temperature'),
                series: <LineSeries<dynamic, int>>[
                  LineSeries<dynamic, int>(
                    dataSource: sensorData,
                    xValueMapper: (data, _) => sensorData.indexOf(data),
                    yValueMapper: (data, _) => data['temp'],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(text: 'Humidity'),
                series: <LineSeries<dynamic, int>>[
                  LineSeries<dynamic, int>(
                    dataSource: sensorData,
                    xValueMapper: (data, _) => sensorData.indexOf(data),
                    yValueMapper: (data, _) => data['humidity'],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
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
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        },
      ),
    );
  }
}
