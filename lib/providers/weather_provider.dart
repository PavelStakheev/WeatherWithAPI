import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/models/forecast_weather.dart';
import 'package:weather/models/hourly_weather.dart';
import 'package:weather/models/daily_forecast.dart'; // Импортируйте вашу модель DailyForecast
import 'package:weather/models/weatherstate.dart';
import '../services/weather_service.dart';

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(ref);
});

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this.ref) : super(WeatherState());

  final Ref ref;

  Future<void> getWeatherByCity(String cityName) async {
    state = state.copyWith(isLoading: true);
    try {
      final weather = await ref.read(weatherServiceProvider).fetchWeatherByCity(cityName);
      state = state.copyWith(weather: weather, currentCity: cityName);
      
      // Получаем почасовой прогноз
      await ref.read(hourlyWeatherProvider.notifier).getHourlyWeather(cityName);
      
      // Получаем прогноз погоды по дням
      await ref.read(forecastProvider.notifier).getForecastWeather(cityName);
      
      // Получаем дневной прогноз
      await ref.read(dailyForecastProvider.notifier).getDailyForecast(cityName);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Новый метод для получения погоды по текущему местоположению
  Future<void> getWeatherByLocation(double latitude, double longitude) async {
    state = state.copyWith(isLoading: true);
    try {
      final weather = await ref.read(weatherServiceProvider).fetchWeatherByCoordinates(latitude, longitude);
      state = state.copyWith(weather: weather, currentCity: 'Current Location');
      
      // Получаем почасовой прогноз
      await ref.read(hourlyWeatherProvider.notifier).getHourlyWeatherByCoordinates(latitude, longitude);
      
      // Получаем прогноз погоды по дням
      await ref.read(forecastProvider.notifier).getForecastWeatherByCoordinates(latitude, longitude);
      
      // Получаем дневной прогноз
      await ref.read(dailyForecastProvider.notifier).getDailyForecastByCoordinates(latitude, longitude);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}


final hourlyWeatherProvider = StateNotifierProvider<HourlyWeatherNotifier, List<HourlyWeather>?>((ref) {
  return HourlyWeatherNotifier(ref);
});

class HourlyWeatherNotifier extends StateNotifier<List<HourlyWeather>?> {
  HourlyWeatherNotifier(this.ref) : super(null);

  final Ref ref;

  Future<void> getHourlyWeather(String cityName) async {
    try {
      final hourlyWeather = await ref.read(weatherServiceProvider).fetchHourlyWeather(cityName);
      state = hourlyWeather;
    } catch (e) {
      state = null;
    }
  }

  // Новый метод для получения почасового прогноза по координатам
  Future<void> getHourlyWeatherByCoordinates(double latitude, double longitude) async {
    try {
      final hourlyWeather = await ref.read(weatherServiceProvider).fetchHourlyWeatherByCoordinates(latitude, longitude);
      state = hourlyWeather;
    } catch (e) {
      state = null;
    }
  }
}


final forecastProvider = StateNotifierProvider<ForecastNotifier, List<ForecastWeather>?>((ref) {
  return ForecastNotifier(ref);
});

class ForecastNotifier extends StateNotifier<List<ForecastWeather>?> {
  ForecastNotifier(this.ref) : super(null);

  final Ref ref;

  Future<void> getForecastWeather(String cityName) async {
    try {
      final forecast = await ref.read(weatherServiceProvider).fetchWeatherForecast(cityName);
      state = forecast;
    } catch (e) {
      state = null;
    }
  }

  // Новый метод для получения прогноза по координатам
  Future<void> getForecastWeatherByCoordinates(double latitude, double longitude) async {
    try {
      final forecast = await ref.read(weatherServiceProvider).fetchWeatherForecastByCoordinates(latitude, longitude);
      state = forecast;
    } catch (e) {
      state = null;
    }
  }
}


// Новый провайдер для дневного прогноза
final dailyForecastProvider = StateNotifierProvider<DailyForecastNotifier, List<DailyForecast>?>((ref) {
  return DailyForecastNotifier(ref);
});

class DailyForecastNotifier extends StateNotifier<List<DailyForecast>?> {
  DailyForecastNotifier(this.ref) : super(null);

  final Ref ref;

  Future<void> getDailyForecast(String cityName) async {
    try {
      final dailyForecast = await ref.read(weatherServiceProvider).fetchDailyForecast(cityName);
      state = dailyForecast;
    } catch (e) {
      state = null;
    }
  }

  // Новый метод для получения дневного прогноза по координатам
  Future<void> getDailyForecastByCoordinates(double latitude, double longitude) async {
    try {
      final dailyForecast = await ref.read(weatherServiceProvider).fetchDailyForecastByCoordinates(latitude, longitude);
      state = dailyForecast;
    } catch (e) {
      state = null;
    }
  }
}


final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService(); // Создаем экземпляр WeatherService
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now(); // Устанавливаем начальную дату
});
