import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/screens/forecast_screen.dart';
import 'package:weather/screens/weather_screen.dart';

class NavBarScreen extends ConsumerStatefulWidget {
  NavBarScreen({super.key});

  @override
  ConsumerState<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends ConsumerState<NavBarScreen> {
  bool isHourlyView = true;
  int _selectedIndex = 0; // Индекс выбранного экрана

  // Список экранов для навигации
  final List<Widget> _screens = [
    WeatherScreen(), // Экран текущей погоды
    ForecastScreen(cityName: 'Default City'), // Экран прогноза
  ];

  // Метод для изменения выбранного экрана
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Отображаем выбранный экран
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: 'Current Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Forecast',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
      ),
    );
  }
}
