class HourlyWeather {
  final String time;
  final double temperature;
  final String condition;
  final double windSpeed;
  final int humidity;
  final String iconUrl;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.humidity,
    required this.iconUrl,
  });
}
