import 'package:weather/models/hourly_weather.dart';

class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final double feelsLike;
  final int humidity;
  final String iconUrl; // Новое поле для URL иконки погоды
  final double windKph;
  final double prec;
  final List<HourlyWeather> hourlyForecasts;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.feelsLike,
    required this.humidity,
    required this.iconUrl, // Добавляем новое поле в конструктор
    required this.prec,
    required this.windKph,
    required this.hourlyForecasts
  });


   
}
