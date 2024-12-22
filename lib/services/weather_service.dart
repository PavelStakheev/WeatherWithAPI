import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather/models/daily_forecast.dart';
import 'package:weather/models/forecast_weather.dart';
import 'package:weather/models/hourly_weather.dart';
import '../models/weather.dart';

class WeatherService {
  final String apiKey = 'ec834052d25042b7922152721240612'; // Замените на ваш API-ключ

  Future<Weather?> fetchWeatherByCity(String cityName) async {
  final encodedCityName = Uri.encodeComponent(cityName);
  final url = 'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$encodedCityName&aqi=no';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    print(response.headers['content-type']); // Проверка заголовка
    final data = json.decode(utf8.decode(response.bodyBytes)); // Декодирование
    return Weather(
      cityName: data['location']['name'],
      temperature: data['current']['temp_c'],
      description: data['current']['condition']['text'],
      feelsLike: data['current']['feelslike_c'],
      humidity: data['current']['humidity'],
      iconUrl: data['current']['condition']['icon'], 
      prec: data['current']['precip_in'] ?? 0, 
      windKph: data['current']['wind_kph'], 
      hourlyForecasts: [],
    );
  } else {
    print('Ошибка: ${response.statusCode} - ${response.body}');
    return null;
  }
}


 Future<Weather?> fetchWeatherByCoordinates(double latitude, double longitude) async {
  final url = 'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$latitude,$longitude&aqi=no';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Проверка заголовка Content-Type
    print(response.headers['content-type']); // Для отладки

    // Декодирование ответа
    final data = json.decode(utf8.decode(response.bodyBytes)); // Используем декодирование

    return Weather(
      cityName: data['location']['name'],
      temperature: data['current']['temp_c'],
      description: data['current']['condition']['text'],
      feelsLike: data['current']['feelslike_c'],
      humidity: data['current']['humidity'],
      iconUrl: data['current']['condition']['icon'], 
      prec: data['current']['precip_in'] ?? 0, 
      windKph: data['current']['wind_kph'], 
      hourlyForecasts: [],
    );
  } else {
    print('Ошибка: ${response.statusCode} - ${response.body}');
    return null;
  }
}


  Future<List<HourlyWeather>?> fetchHourlyWeather(String cityName) async {
    final url = 'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=1&aqi=no&alerts=no';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<HourlyWeather> hourlyForecastList = [];

      for (var hour in data['forecast']['forecastday'][0]['hour']) {
        hourlyForecastList.add(HourlyWeather(
          time: hour['time'],
          temperature: hour['temp_c'],
          condition: hour['condition']['text'],
          windSpeed: hour['wind_kph'],
          humidity: hour['humidity'],
          iconUrl: hour['condition']['icon'],
        ));
      }
      return hourlyForecastList;
    } else {
      print('Ошибка: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<List<HourlyWeather>?> fetchHourlyWeatherByCoordinates(double latitude, double longitude) async {
    final url = 'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=1&aqi=no&alerts=no';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<HourlyWeather> hourlyForecastList = [];

      for (var hour in data['forecast']['forecastday'][0]['hour']) {
        hourlyForecastList.add(HourlyWeather(
          time: hour['time'],
          temperature: hour['temp_c'],
          condition: hour['condition']['text'],
          windSpeed: hour['wind_kph'],
          humidity: hour['humidity'],
          iconUrl: hour['condition']['icon'],
        ));
      }
      return hourlyForecastList;
    } else {
      print('Ошибка: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<List<DailyForecast>?> fetchDailyForecast(String cityName) async {
    final url = 'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=14&aqi=no&alerts=no';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<DailyForecast> dailyForecastList = [];

      for (var day in data['forecast']['forecastday']) {
        dailyForecastList.add(DailyForecast(
          date: day['date'],
          iconUrl: day['day']['condition']['icon'],
          temperature: day['day']['avgtemp_c'],
          condition: day['day']['condition']['text'],
        ));
      }
      return dailyForecastList;
    } else {
      print('Ошибка: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<List<DailyForecast>?> fetchDailyForecastByCoordinates(double latitude, double longitude) async {
    final url = 'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=14&aqi=no&alerts=no';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<DailyForecast> dailyForecastList = [];

      for (var day in data['forecast']['forecastday']) {
        dailyForecastList.add(DailyForecast(
          date: day['date'],
          iconUrl: day['day']['condition']['icon'],
          temperature: day['day']['avgtemp_c'],
          condition: day['day']['condition']['text'],
        ));
      }
      return dailyForecastList;
    } else {
      print('Ошибка: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<List<ForecastWeather>?> fetchWeatherForecast(String cityName) async {
    final url = 'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=7&aqi=no&alerts=no';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<ForecastWeather> forecastList = [];

      for (var day in data['forecast']['forecastday']) {
        forecastList.add(ForecastWeather(
          date: day['date'],
          morningDescription: day['hour'][0]['condition']['text'] ?? 'Нет данных',
          dayDescription: day['hour'][12]['condition']['text'] ?? 'Нет данных',
          eveningDescription: day['hour'][18]['condition']['text'] ?? 'Нет данных',
          nightDescription: day['hour'][21]['condition']['text'] ?? 'Нет данных',
          morningIconUrl: day['hour'][0]['condition']['icon'] ?? '',
          dayIconUrl: day['hour'][12]['condition']['icon'] ?? '',
          eveningIconUrl: day['hour'][18]['condition']['icon'] ?? '',
          nightIconUrl: day['hour'][21]['condition']['icon'] ?? '',
          morningTemperature: day['hour'][0]['temp_c'] ?? 0.0,
          dayTemperature: day['hour'][12]['temp_c'] ?? 0.0,
          eveningTemperature: day['hour'][18]['temp_c'] ?? 0.0,
          nightTemperature: day['hour'][21]['temp_c'] ?? 0.0,
          morninghumidity: day['hour'][0]['humidity'] ?? 0,
          dayhumidity: day['hour'][12]['humidity'] ?? 0,
          eveninghumidity: day['hour'][18]['humidity'] ?? 0,
          nighthumidity: day['hour'][21]['humidity'] ?? 0,
          morningwindKph: day['hour'][0]['wind_kph'] ?? 0.0,
          daywindKph: day['hour'][12]['wind_kph'] ?? 0.0,
          eveningwindKph: day['hour'][18]['wind_kph'] ?? 0.0,
          nightwindKph: day['hour'][21]['wind_kph'] ?? 0.0,
          morningprec: day['hour'][0]['pressure_mb'] ?? 0.0,
          dayprec: day['hour'][12]['pressure_mb'] ?? 0.0,
          eveningprec: day['hour'][18]['pressure_mb'] ?? 0.0,
          nightprec: day['hour'][21]['pressure_mb'] ?? 0.0,
          morninggustKph: day['hour'][0]['gust_kph'] ?? 0.0,
          daygustKph: day['hour'][12]['gust_kph'] ?? 0.0,
          eveninggustKph: day['hour'][18]['gust_kph'] ?? 0.0,
          nightgustKph: day['hour'][21]['gust_kph'] ?? 0.0,
        ));
      }
      return forecastList;
    } else {
      print('Ошибка: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<List<ForecastWeather>?> fetchWeatherForecastByCoordinates(double latitude, double longitude) async {
    final url = 'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=7&aqi=no&alerts=no';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<ForecastWeather> forecastList = [];

      for (var day in data['forecast']['forecastday']) {
        forecastList.add(ForecastWeather(
          date: day['date'],
          morningDescription: day['hour'][0]['condition']['text'] ?? 'Нет данных',
          dayDescription: day['hour'][12]['condition']['text'] ?? 'Нет данных',
          eveningDescription: day['hour'][18]['condition']['text'] ?? 'Нет данных',
          nightDescription: day['hour'][21]['condition']['text'] ?? 'Нет данных',
          morningIconUrl: day['hour'][0]['condition']['icon'] ?? '',
          dayIconUrl: day['hour'][12]['condition']['icon'] ?? '',
          eveningIconUrl: day['hour'][18]['condition']['icon'] ?? '',
          nightIconUrl: day['hour'][21]['condition']['icon'] ?? '',
          morningTemperature: day['hour'][0]['temp_c'] ?? 0.0,
          dayTemperature: day['hour'][12]['temp_c'] ?? 0.0,
          eveningTemperature: day['hour'][18]['temp_c'] ?? 0.0,
          nightTemperature: day['hour'][21]['temp_c'] ?? 0.0,
          morninghumidity: day['hour'][0]['humidity'] ?? 0,
          dayhumidity: day['hour'][12]['humidity'] ?? 0,
          eveninghumidity: day['hour'][18]['humidity'] ?? 0,
          nighthumidity: day['hour'][21]['humidity'] ?? 0,
          morningwindKph: day['hour'][0]['wind_kph'] ?? 0.0,
          daywindKph: day['hour'][12]['wind_kph'] ?? 0.0,
          eveningwindKph: day['hour'][18]['wind_kph'] ?? 0.0,
          nightwindKph: day['hour'][21]['wind_kph'] ?? 0.0,
          morningprec: day['hour'][0]['pressure_mb'] ?? 0.0,
          dayprec: day['hour'][12]['pressure_mb'] ?? 0.0,
          eveningprec: day['hour'][18]['pressure_mb'] ?? 0.0,
          nightprec: day['hour'][21]['pressure_mb'] ?? 0.0,
          morninggustKph: day['hour'][0]['gust_kph'] ?? 0.0,
          daygustKph: day['hour'][12]['gust_kph'] ?? 0.0,
          eveninggustKph: day['hour'][18]['gust_kph'] ?? 0.0,
          nightgustKph: day['hour'][21]['gust_kph'] ?? 0.0,
        ));
      }
      return forecastList;
    } else {
      print('Ошибка: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
