import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Open-Meteo API client (free, no API key needed).
class WeatherApi {
  final Dio _dio;

  WeatherApi({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Get current weather for coordinates.
  Future<WeatherData?> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,weather_code',
          'timezone': 'auto',
        },
      );

      final current = response.data['current'] as Map<String, dynamic>;
      return WeatherData(
        temperature: (current['temperature_2m'] as num).toDouble(),
        weatherCode: current['weather_code'] as int,
      );
    } catch (e) {
      debugPrint('Weather API error: $e');
      return null;
    }
  }

  /// Get weather description from WMO code.
  static String getWeatherDescription(int code) {
    // WMO Weather interpretation codes
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Heavy rain';
    if (code <= 86) return 'Snow showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  /// Get weather icon from WMO code.
  static String getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '⛈️';
    if (code <= 86) return '🌨️';
    if (code <= 99) return '⛈️';
    return '❓';
  }
}

/// Weather data model.
class WeatherData {
  final double temperature;
  final int weatherCode;

  const WeatherData({
    required this.temperature,
    required this.weatherCode,
  });

  String get description => WeatherApi.getWeatherDescription(weatherCode);
  String get icon => WeatherApi.getWeatherIcon(weatherCode);
}
