class Sensor {
  int? id;
  String? timestamp;
  double? temperature;
  double? humidity;
  double? ph;
  double? soilMoisture;
  int? farm;

  Sensor(
      {this.id,
      this.timestamp,
      this.temperature,
      this.humidity,
      this.ph,
      this.soilMoisture,
      this.farm});

  Sensor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    timestamp = json['timestamp'];
    temperature = json['temperature'];
    humidity = json['humidity'];
    ph = json['ph'];
    soilMoisture = json['soil_moisture'];
    farm = json['farm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['timestamp'] = this.timestamp;
    data['temperature'] = this.temperature;
    data['humidity'] = this.humidity;
    data['ph'] = this.ph;
    data['soil_moisture'] = this.soilMoisture;
    data['farm'] = this.farm;
    return data;
  }
}