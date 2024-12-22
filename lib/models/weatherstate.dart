import 'package:weather/models/weather.dart';

class WeatherState {
  final bool isLoading;
  final Weather? weather;
  final String? error;
  final String? currentCity; // Добавляем поле для текущего города

  WeatherState({
    this.isLoading = false,
    this.weather,
    this.error,
    this.currentCity,
  });

  WeatherState copyWith({
    bool? isLoading,
    Weather? weather,
    String? error,
    String? currentCity,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      weather: weather ?? this.weather,
      error: error ?? this.error,
      currentCity: currentCity ?? this.currentCity,
    );
  }
}
