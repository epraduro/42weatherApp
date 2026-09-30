import 'package:flutter/material.dart';

class CurrentWeatherTab extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String? city;
  final bool isLoading;
  final String? errorMessage;
  final bool isOffline;
  final bool isFind;

  const CurrentWeatherTab({
    this.weatherData,
    this.city,
    required this.isLoading,
    this.errorMessage,
    required this.isOffline,
    required this.isFind,
    super.key,
  });

  String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Fog';
      case 48:
        return 'Depositing rime fog';
      case 51:
        return 'Light drizzle';
      case 53:
        return 'Moderate drizzle';
      case 55:
        return 'Dense intensity drizzle';
      case 56:
        return 'Light freezing drizzle';
      case 57:
        return 'Dense intensity freezing drizzle';
      case 61:
        return 'Slight rain';
      case 63:
        return 'Moderate rain';
      case 65:
        return 'Heavy intensity rain';
      case 66: 
        return 'Light freezing rain';
      case 67:
        return 'Heavy intensity freezing rain';
      case 71:
        return 'Slight snow fall';
      case 73:
        return 'Moderate snow fall';
      case 75:
        return 'Heavy intensity snow fall';
      case 77:
        return 'Snow grains';
      case 80:
        return 'Slight rain showers';
      case 81:
        return 'Moderate rain showers';
      case 82:
        return 'Violent rain showers';
      case 85:
        return 'Slight snow showers';
      case 86:
        return 'Heavy snow showers';
      default:
        return 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(
            color: Colors.red
          )
        )
      );
    }

    if (isFind == false) {
      return Center(
        child: Text("")
      );
    }

    if ((weatherData == null || city == null)) {
      return const Center(
        child: Text(
          'Veuillez entrer une ville ou utiliser la géolocalisation'
        )
      );
    }

    final current = weatherData!['current'];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            city!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${current['temperature_2m']}°C',
            style: const TextStyle(
              fontSize: 20
            )
          ),
          Text(
            _getWeatherDescription(current['weather_code']),
            style: const TextStyle(
              fontSize: 20
            )
          ),
          Text(
            '${current['wind_speed_10m']}km/h',
            style: const TextStyle(
              fontSize: 20
            )
          )
        ],
      ),
    );
  }
}