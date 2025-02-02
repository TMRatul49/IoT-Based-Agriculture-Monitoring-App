import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/sensor.dart';
import '../state/farm_state.dart';
import '../state/sensor_state.dart';

class FarmDetailsScreens extends StatefulWidget {
  static const routeName = '/farm-details-screens';

  @override
  _FarmDetailsScreensState createState() => _FarmDetailsScreensState();
}

class _FarmDetailsScreensState extends State<FarmDetailsScreens> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        // Perform any necessary operations to reload the screen here
        _reloadData();
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _reloadData() async {
    final id = ModalRoute.of(context)?.settings.arguments as int;
    await Provider.of<SensorState>(context, listen: false).getSensors(id);
    // Add any other data fetching or processing logic here as needed
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as int;
    final farm = Provider.of<FarmState>(context).singleFarm(id);

    return FutureBuilder<List<Sensor>>(
      future: Provider.of<SensorState>(context, listen: false).getSensors(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No sensor data found for this farm.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          );
        } else {
          List<Sensor> sensors = snapshot.data!;

          if (sensors.isEmpty) {
            return Center(
              child: Text(
                'No sensor data found for this farm.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                farm.name ?? 'Farm Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SensorChart(
                    sensorType: 'Temperature',
                    sensorData: sensors,
                    sensorIcon: Icons.thermostat,
                    unit: '°C',
                    color: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.2),
                  ),
                  SensorChart(
                    sensorType: 'Humidity',
                    sensorData: sensors,
                    sensorIcon: Icons.opacity,
                    unit: '%',
                    color: Colors.blue,
                    backgroundColor: Colors.blue.withOpacity(0.2),
                  ),
                  SensorChart(
                    sensorType: 'pH',
                    sensorData: sensors,
                    sensorIcon: Icons.bubble_chart,
                    unit: '',
                    color: Colors.green,
                    backgroundColor: Colors.green.withOpacity(0.2),
                  ),
                  SensorChart(
                    sensorType: 'Soil Moisture',
                    sensorData: sensors,
                    sensorIcon: Icons.wb_sunny,
                    unit: '%',
                    color: Colors.orange,
                    backgroundColor: Colors.orange.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class SensorChart extends StatelessWidget {
  final String sensorType;
  final List<Sensor> sensorData;
  final IconData sensorIcon;
  final String unit;
  final Color color;
  final Color backgroundColor;

  SensorChart({
    required this.sensorType,
    required this.sensorData,
    required this.sensorIcon,
    required this.unit,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    List<ChartData> historicalData = sensorData.map((sensor) {
      return ChartData(
        sensor.timestamp ?? '',
        sensorType == 'Temperature'
            ? sensor.temperature ?? 0.0
            : sensorType == 'Humidity'
                ? sensor.humidity ?? 0.0
                : sensorType == 'pH'
                    ? sensor.ph ?? 0.0
                    : sensor.soilMoisture ?? 0.0,
      );
    }).toList();

    // Get the last value for the selected sensor type
    double lastValue = sensorData.isNotEmpty
        ? sensorType == 'Temperature'
            ? sensorData.last.temperature ?? 0.0
            : sensorType == 'Humidity'
                ? sensorData.last.humidity ?? 0.0
                : sensorType == 'pH'
                    ? sensorData.last.ph ?? 0.0
                    : sensorData.last.soilMoisture ?? 0.0
        : 0.0;

    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$sensorType Data:',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          SfCartesianChart(
            plotAreaBorderWidth: 0,
            title: ChartTitle(
                text: sensorType, textStyle: TextStyle(color: color)),
            primaryXAxis: CategoryAxis(
              title: AxisTitle(
                text: 'Time',
                textStyle: TextStyle(color: color),
              ),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(
                text: 'Values',
                textStyle: TextStyle(color: color),
              ),
            ),
            legend: Legend(
              isVisible: false, // Remove the legend
            ),
            series: <ChartSeries<ChartData, String>>[
              SplineSeries<ChartData, String>(
                color: color,
                markerSettings: MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.circle,
                  borderColor: color,
                  borderWidth: 2,
                  width: 5,
                  height: 5,
                ),
                dataSource: historicalData,
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.value,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: color),
                ),
              ),
            ],
          ),
          // Display the last value for the selected sensor type
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Last $sensorType: $lastValue$unit',
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.category, this.value);

  final String category;
  final double value;
}
