import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final double temperature;
  final String condition;
  final String icon;
  final String cityName;
  final String stylingAdvice;
  final bool isCold;
  final bool isRainy;

  const WeatherInfo({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.cityName,
    required this.stylingAdvice,
    required this.isCold,
    required this.isRainy,
  });

  factory WeatherInfo.defaultWeather() {
    return const WeatherInfo(
      temperature: 22.0,
      condition: 'Agradável',
      icon: '🌤️',
      cityName: 'São Paulo',
      stylingAdvice: 'Clima ameno ideal para combinações leves com uma terceira peça suave.',
      isCold: false,
      isRainy: false,
    );
  }
}

class WeatherService {
  WeatherService._();
  static final WeatherService instance = WeatherService._();

  WeatherInfo? _cachedWeather;
  DateTime? _lastFetch;

  Future<WeatherInfo> getCurrentWeather({double lat = -23.5505, double lon = -46.6333, String city = 'São Paulo'}) async {
    final now = DateTime.now();
    if (_cachedWeather != null && _lastFetch != null && now.difference(_lastFetch!).inMinutes < 30) {
      return _cachedWeather!;
    }

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,precipitation,weather_code&timezone=auto',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>;
        final temp = (current['temperature_2m'] as num).toDouble();
        final precipitation = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
        final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;

        String condition = 'Ensolarado';
        String icon = '☀️';
        bool isRainy = precipitation > 0.1 || (weatherCode >= 51 && weatherCode <= 67);
        bool isCold = temp < 19.0;

        if (isRainy) {
          condition = 'Chuvoso';
          icon = '🌧️';
        } else if (weatherCode >= 1 && weatherCode <= 3) {
          condition = 'Parcialmente Nublado';
          icon = '⛅';
        } else if (weatherCode >= 45 && weatherCode <= 48) {
          condition = 'Nublado';
          icon = '☁️';
        } else if (temp >= 28) {
          condition = 'Quente';
          icon = '🔥';
        } else if (isCold) {
          condition = 'Frio';
          icon = '🧣';
        }

        String advice;
        if (isRainy) {
          advice = 'Dia com chuva. Evite calçados de camurça ou tecido claro; priorize casacos impermeáveis e tons escuros.';
        } else if (temp >= 28) {
          advice = 'Dia quente ($temp°C). Escolha tecidos naturais como linho e algodão, e tons claros para manter o frescor.';
        } else if (isCold) {
          advice = 'Dia frio ($temp°C). Aposte em sobreposições inteligentes: malha sobre camisa ou jaqueta estruturada.';
        } else {
          advice = 'Clima agradável ($temp°C). Perfeito para um look equilibrado com terceira peça versátil.';
        }

        final info = WeatherInfo(
          temperature: temp,
          condition: condition,
          icon: icon,
          cityName: city,
          stylingAdvice: advice,
          isCold: isCold,
          isRainy: isRainy,
        );

        _cachedWeather = info;
        _lastFetch = now;
        return info;
      }
    } catch (e) {
      debugPrint('Aviso: Falha ao obter clima online: $e. Usando clima padrão.');
    }

    return WeatherInfo.defaultWeather();
  }
}
