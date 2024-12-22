class ForecastWeather {
  final String date;
  final String morningDescription;
  final String dayDescription;
  final String eveningDescription;
  final String nightDescription;
  final String morningIconUrl;
  final String dayIconUrl;
  final String eveningIconUrl;
  final String nightIconUrl;
  final double? morningTemperature;
  final double? dayTemperature;
  final double? eveningTemperature;
  final double? nightTemperature;  
  final int? morninghumidity;
  final int? dayhumidity;
  final int? eveninghumidity;
  final int? nighthumidity;
  final double? morningwindKph;
  final double? daywindKph;
  final double? eveningwindKph;
  final double? nightwindKph;
  final double? morninggustKph;
  final double? daygustKph;
  final double? eveninggustKph;
  final double? nightgustKph;
  final double? morningprec;
  final double? dayprec;
  final double? eveningprec;
  final double? nightprec;

  ForecastWeather( {
    required this.date,
    required this.morningDescription,
    required this.dayDescription,
    required this.eveningDescription,
    required this.nightDescription,
    required this.morningIconUrl,
    required this.dayIconUrl,
    required this.eveningIconUrl,
    required this.nightIconUrl,
    this.morningTemperature,
    this.dayTemperature,
    this.eveningTemperature,
    this.nightTemperature,
    this.dayhumidity,
    this.morninghumidity, 
    this.eveninghumidity, 
    this.nighthumidity, 
    this.morningwindKph, 
    this.daywindKph, 
    this.eveningwindKph, 
    this.nightwindKph, 
    this.morningprec, 
    this.dayprec, 
    this.eveningprec, 
    this.nightprec,
    this.morninggustKph, 
    this.daygustKph, 
    this.eveninggustKph, 
    this.nightgustKph,
  });
}
