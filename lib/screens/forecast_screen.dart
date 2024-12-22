import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forecast_weather.dart';
import '../providers/weather_provider.dart'; // Импортируйте ваш провайдер
import 'package:intl/intl.dart';


class ForecastScreen extends ConsumerWidget {
  final String cityName;

  ForecastScreen({required this.cityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastState = ref.watch(forecastProvider); // Получаем состояние прогноза
    final selectedDate = ref.watch(selectedDateProvider); // Получаем выбранную дату

    // Проверяем, что forecastState не null
    if (forecastState == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade300,
          title: Text('Прогноз погоды на 7 дней'),
        ),
        body: Center(child: CircularProgressIndicator()), // Показываем индикатор загрузки
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: Text('Прогноз погоды на 7 дней'),
      ),
      body: Column(
        children: [
          // Виджет календаря на неделю
          _buildWeekCalendar(selectedDate, (date) {
            ref.read(selectedDateProvider.notifier).state = date; // Обновляем выбранную дату
          }),
          Expanded(
            child: _buildForecastDetails(forecastState, selectedDate), // Передаем forecastState
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar(DateTime selectedDate, Function(DateTime) onDateSelected) {
    DateTime today = DateTime.now(); // Сегодняшняя дата
    return Container(
      color: Colors.grey.shade300,
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          DateTime day = today.add(Duration(days: index)); // Добавляем дни к сегодняшнему дню
          bool isSelected = selectedDate.year == day.year && selectedDate.month == day.month && selectedDate.day == day.day;
          return GestureDetector(
            onTap: () {
              onDateSelected(day); // Обновляем выбранную дату
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(DateFormat.E().format(day),
                  style: TextStyle(color: Colors.grey.shade600)),
                if (isSelected) // Сокращенное название дня
                  Container(
                    margin: EdgeInsets.only(top: 4.0),
                    height: 30.0, // Высота кружочка
                    width: 30.0, // Ширина кружочка
                    decoration: BoxDecoration(
                      color: Colors.red, // Цвет кружочка
                      shape: BoxShape.circle, // Делаем кружочек
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}', // Число месяца внутри кружочка
                        style: TextStyle(
                          color: Colors.white, // Цвет текста
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Text('${day.day}',
                    style: TextStyle(fontWeight: FontWeight.bold)), // Число месяца, если день не выбран
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildForecastDetails(List<ForecastWeather> forecastList, DateTime selectedDate) {
    // Фильтруем прогноз по выбранной дате
    final selectedForecast = forecastList.where((forecastDay) => forecastDay.date.startsWith(DateFormat('yyyy-MM-dd').format(selectedDate))).toList();

    return ListView.builder(
      itemCount: selectedForecast.length,
      itemBuilder: (context, index) {
        final forecastPeriod = selectedForecast[index];

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Выравнивание элементов
              children: [
                _buildForecastTile(forecastPeriod.morningIconUrl, 'Утро', forecastPeriod.morningDescription, forecastPeriod.morningTemperature),
                _buildForecastTile(forecastPeriod.dayIconUrl, 'День', forecastPeriod.dayDescription, forecastPeriod.dayTemperature),
                _buildForecastTile(forecastPeriod.eveningIconUrl, 'Вечер', forecastPeriod.eveningDescription, forecastPeriod.eveningTemperature),
                _buildForecastTile(forecastPeriod.nightIconUrl, 'Ночь', forecastPeriod.nightDescription, forecastPeriod.nightTemperature),
              ],
            ),
            Container(height: 5, decoration: BoxDecoration(color: Colors.grey.shade300)),
            SizedBox(height: 15),
            Row(
              children: [
                const SizedBox(width: 10),
                SizedBox(
                  height: 25,
                  width: 25,
                  child: Image.asset('assets/humidity.png')),
                  SizedBox(width: 10),
                  Text('Humidity', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey.shade700
                    )),
                
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildForecastHumidity(forecastPeriod.morninghumidity ?? 0),
                _buildForecastHumidity(forecastPeriod.dayhumidity ?? 0),
                _buildForecastHumidity(forecastPeriod.eveninghumidity ?? 0),
                _buildForecastHumidity(forecastPeriod.nighthumidity ?? 0),
              ],
            ),
            Container(height: 5, decoration: BoxDecoration(color: Colors.grey.shade300)),
            SizedBox(height: 15),
            Row(
              children: [
                const SizedBox(width: 10),
                SizedBox(
                  height: 25,
                  width: 25,
                  child: Image.asset('assets/wind.png')),
                  SizedBox(width: 10),
                  Text('Wind', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey.shade700
                    )),
                
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildForecastWind(forecastPeriod.morningwindKph ?? 0, forecastPeriod.morninggustKph ?? 0),
                _buildForecastWind(forecastPeriod.daywindKph ?? 0, forecastPeriod.daygustKph ?? 0),
                _buildForecastWind(forecastPeriod.eveningwindKph ?? 0, forecastPeriod.eveninggustKph ?? 0),
                _buildForecastWind(forecastPeriod.nightwindKph ?? 0, forecastPeriod.nightgustKph ?? 0)
              ],
            ),
            Container(height: 5, decoration: BoxDecoration(color: Colors.grey.shade300)),
            SizedBox(height: 15),
            Row(
              
              children: [
                const SizedBox(width: 10),
                SizedBox(
                  height: 25,
                  width: 25,
                  child: Image.asset('assets/pres.png')),
                  SizedBox(width: 10),
                  Text('Pressure', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey.shade700
                    )),
                
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildForecastPres(forecastPeriod.morningprec ?? 0),
                _buildForecastPres(forecastPeriod.dayprec ?? 0),
                _buildForecastPres(forecastPeriod.eveningprec ?? 0),
                _buildForecastPres(forecastPeriod.nightprec ?? 0),

              ],
            ),
            Container(
              height: 70,
              decoration: BoxDecoration(color: Colors.grey.shade300),)
          ],
        );
      },
    );
  }

  // Метод для создания виджета прогноза
  Widget _buildForecastTile(String iconUrl, String title, String description, double? temperature) {
    return Container(
      width: 80, // Задайте ширину контейнера
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(title),
          Image.network(
            'https:$iconUrl',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error);
            },
          ),
          Text('${temperature ?? 0.0} °C',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  Widget _buildForecastHumidity(int humidity) {
    return SizedBox(
      width: 80, // Задайте ширину контейнера
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text('${humidity ?? 0.0} %',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
           const SizedBox(height: 20)
        ],
        
      ),
    );
  }

  Widget _buildForecastWind(double wind, double gust) {
    return SizedBox(
      width: 80, // Задайте ширину контейнера
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text('${wind ?? 0.0} km/h',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          Text('to ${gust ?? 0.0} km/h', 
            style: TextStyle(
              fontSize: 12
            ),),
          const SizedBox(height: 20)  
        ],
      ),
    );
  }

  Widget _buildForecastPres(double pres) {
    return SizedBox(
      width: 80, // Задайте ширину контейнера
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text('$pres',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          Text('mm Hg',
            style: TextStyle(
              color: Colors.grey.shade700
            ),),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}

