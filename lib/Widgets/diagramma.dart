import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weather/models/hourly_weather.dart';

class HourlyWeatherChart extends StatelessWidget {
  final List<HourlyWeather> hourlyWeatherData;

  const HourlyWeatherChart({Key? key, required this.hourlyWeatherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filteredData = hourlyWeatherData.where((weather) {
      final weatherTime = DateTime.parse(weather.time);
      return weatherTime.isAfter(now) || weatherTime.isAtSameMomentAs(now);
    }).toList();

    if (filteredData.isEmpty) {
      return Center(child: Text('Нет данных для отображения'));
    }

    final minY = filteredData.map((weather) => weather.temperature).reduce((a, b) => a < b ? a : b).toDouble();
    final maxY = filteredData.map((weather) => weather.temperature).reduce((a, b) => a > b ? a : b).toDouble();
    final height = 300.0; // Высота графика

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          LineChart(
            LineChartData(
              gridData: FlGridData(show: false), // Отключаем сетку
              titlesData: FlTitlesData(show: false), // Отключаем заголовки осей
              borderData: FlBorderData(show: false), // Отключаем границы
              lineBarsData: [
                LineChartBarData(
                  spots: filteredData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value.temperature.toDouble(); // Преобразуем в double
                    return FlSpot(index.toDouble(), value);
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                ),
              ],
              minX: 0,
              maxX: filteredData.length.toDouble() - 1,
              minY: minY,
              maxY: maxY,
            ),
          ),
          // Добавляем текстовые метки с температурами над точками
          ...filteredData.asMap().entries.map((entry) {
            final index = entry.key;
            final temperature = entry.value.temperature.toDouble(); // Преобразуем в double
            final positionY = height - ((temperature - minY) / (maxY - minY) * height); // Вычисляем Y позицию
            return Positioned(
              left: index.toDouble() * (MediaQuery.of(context).size.width / filteredData.length) - 20,
              bottom: positionY + 5, // Позиция для температуры
              child: Text(
                '$temperature°',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            );
          }).toList(),
          // Добавляем временные метки под графиком
          ...filteredData.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value.time;
            final dateTime = DateTime.parse(time);
            return Positioned(
              left: index.toDouble() * (MediaQuery.of(context).size.width / filteredData.length) - 20,
              bottom: 0, // Позиция для временных меток
              child: Text(
                '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.black, fontSize: 10),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

