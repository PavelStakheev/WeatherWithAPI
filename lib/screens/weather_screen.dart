import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/models/daily_forecast.dart';
import 'package:weather/models/hourly_weather.dart';
import 'package:weather/models/weather.dart';
import '../providers/weather_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';



class WeatherScreen extends ConsumerStatefulWidget {
  WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool isHourlyView = true;
  List<String> _cityHistory = []; 
  
  
  @override
  void initState() {
    super.initState();
    _loadCityHistory(); // Загружаем историю городов при инициализации
  }

Future<void> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Проверяем, включена ли служба геолокации
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Геолокация отключена, покажите сообщение
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Разрешение не было предоставлено, покажите сообщение
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Разрешение было отклонено навсегда, покажите сообщение
    return;
  }

  // Получаем текущее местоположение
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  _getWeatherByLocation(position.latitude, position.longitude);
}

// Метод для получения погоды по координатам
  void _getWeatherByLocation(double latitude, double longitude) {
    ref.read(weatherProvider.notifier).getWeatherByLocation(latitude, longitude);
  }

  Future<void> _loadCityHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cityHistory = prefs.getStringList('cityHistory') ?? []; // Загружаем список или создаем пустой
    });
  }

  // Метод для сохранения истории городов в shared preferences
  Future<void> _saveCityHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('cityHistory', _cityHistory); // Сохраняем список городов
  }

String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('EEE d').format(dateTime); // Краткое название дня и число
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);
    final hourlyWeatherList = ref.watch(hourlyWeatherProvider);
    final dailyForecastList = ref.watch(dailyForecastProvider);

    return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/nebo.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              // Поле ввода для названия города
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Stack(
                      children:[ TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'Enter city name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              final cityName = _cityController.text;
                                if (cityName.isNotEmpty) {
                                  ref.read(weatherProvider.notifier).getWeatherByCity(cityName);
                                  _addCityToHistory(cityName); // Сохраняем город в историю
                                }
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            ref.read(weatherProvider.notifier).getWeatherByCity(value);
                            _addCityToHistory(value); // Сохраняем город в историю
                          }
                        },
                                            ),
                      Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.list),
                        onPressed: () {
                          _showCityHistory(); // Метод для отображения списка городов
                        },
                      ),
                    ),
                    ]
                    
                    ),
                    
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text('Get Weather by Current Location'),
              ),
              // Индикатор загрузки
              if (weatherState.isLoading)
                Center(child: CircularProgressIndicator()),

              // Обработка ошибок
              if (weatherState.error != null)
                Center(child: Text('Error: ${weatherState.error}', style: TextStyle(color: Colors.red))),

              // Отображение текущей погоды
              Expanded(
                child: ListView(
                  children: [
                    if (weatherState.weather != null) ...[
                      _buildCurrentWeatherCard(weatherState.weather!),
                      _buildAdditionalWeatherInfo(weatherState.weather!),
                      const SizedBox(height: 10),
                      _buildToggleButtons(),
                      if (isHourlyView) _buildHourlyForecast(hourlyWeatherList) else _buildDailyForecast(dailyForecastList),
                    ] else ...[
                      Center(child: Text('No data available', style: TextStyle(fontSize: 18, color: Colors.white))),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _addCityToHistory(String cityName) {
    if (!_cityHistory.contains(cityName)) {
      _cityHistory.add(cityName);
      _saveCityHistory(); // Сохраняем обновленный список в shared preferences
    }
  }
    void _showCityHistory() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Saved Cities',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _cityHistory.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_cityHistory[index]),
                        onTap: () {
                          _cityController.text = _cityHistory[index]; // Устанавливаем выбранный город в TextField
                          ref.read(weatherProvider.notifier).getWeatherByCity(_cityHistory[index]); // Получаем погоду для выбранного города
                          Navigator.pop(context); // Закрываем модальное окно
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  Widget _buildCityHistoryDropdown() {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      child: DropdownButton<String>(
        hint: Text('Select a city'),
        items: _cityHistory.map((String city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _cityController.text = newValue; // Устанавливаем выбранный город в TextField
            ref.read(weatherProvider.notifier).getWeatherByCity(newValue); // Получаем погоду для выбранного города
          }
        },
      ),
    );
  }


  Widget _buildCurrentWeatherCard(Weather weather) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 20),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(weather.cityName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('${weather.temperature} °C', style: TextStyle(fontSize: 30)),
                      Text(weather.description, style: TextStyle(fontSize: 18)),
                      Text('Feels Like: ${weather.feelsLike} °C', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  Image.network(
                    'https:${weather.iconUrl}',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAdditionalWeatherInfo(Weather weather) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildWeatherInfoCard('assets/humidity.png', '${weather.humidity} %', 'Humidity'),
          _buildWeatherInfoCard('assets/prec.png', '${weather.prec.toInt()} %', 'Precipitation'),
          _buildWeatherInfoCard('assets/wind.png', '${weather.windKph} km/h', 'Speed of wind'),
        ],
      ),
    );
  }

  Widget _buildWeatherInfoCard(String assetPath, String value, String label) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Image.asset(height: 50, width: 50, assetPath),
            SizedBox(width: 10),
            Column(
              children: [
                Text(value, style: TextStyle(fontSize: 20)),
                Text(label),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildToggleButtons() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Center( // Центрируем кнопки
      child: ToggleButtons(
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text('Hourly')),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text('Daily')),
        ],
        isSelected: [isHourlyView, !isHourlyView],
        onPressed: (int index) {
          setState(() {
            isHourlyView = index == 0; // Если выбран первый элемент, переключаем на часовой режим
          });
        },
        color: Colors.white, // Цвет текста кнопок
        selectedColor: Colors.white, // Цвет текста выбранной кнопки
        fillColor: Colors.blueAccent, // Цвет фона выбранной кнопки
        borderColor: Colors.white, // Цвет границы кнопок
        selectedBorderColor: Colors.blueAccent, // Цвет границы выбранной кнопки
      ),
    ),
  );
}


  Widget _buildHourlyForecast(List<HourlyWeather>? hourlyWeatherList) {
    if (hourlyWeatherList == null || hourlyWeatherList.isEmpty) {
      return Center(child: Text('No hourly data available', style: TextStyle(fontSize: 18, color: Colors.white)));
    }

    return Column(
      children: [
        Text('Hourly Forecast', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: hourlyWeatherList.map((hour) {
              return SizedBox(
                width: 100,
                height: 170,
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(hour.time.split(' ')[1], style: TextStyle(fontSize: 16)),
                        SizedBox(height: 5),
                        Image.network(
                          'https:${hour.iconUrl}',
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                        SizedBox(height: 5),
                        Text('${hour.temperature} °C', style: TextStyle(fontSize: 18)),
                        Text(hour.condition, style: TextStyle(fontSize: 12),),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast(List<DailyForecast>? dailyForecastList) {
  if (dailyForecastList == null || dailyForecastList.isEmpty) {
    return Center(child: Text('No daily data available', style: TextStyle(fontSize: 18, color: Colors.white)));
  }

  return Column(
    children: [
      Text('Daily Forecast', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: dailyForecastList.map((day) {
            return SizedBox(
              width: 100,
              height: 170,
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(formatDate(day.date), style: TextStyle(fontSize: 16)), // Изменено здесь
                      SizedBox(height: 5),
                      Image.network(
                        'https:${day.iconUrl}',
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error);
                        },
                      ),
                      SizedBox(height: 5),
                      Text('${day.temperature} °C', style: TextStyle(fontSize: 18)),
                      Text(day.condition, style: TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis,softWrap: true),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

}

