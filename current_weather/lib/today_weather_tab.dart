import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodayWeatherTab extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String? city;
  final bool isLoading;
  final String? errorMessage;

  const TodayWeatherTab({
    this.weatherData,
    this.city,
    required this.isLoading,
    this.errorMessage,
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
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    
    if ((weatherData == null || city == null)) {
      return Center( 
        child: Text(
          'Veuillez entrer une ville\n ou\n utiliser la géolocalisation',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final hourly = weatherData!['hourly'];
    final now = DateTime.now();
    final todayHours = hourly['time']
        .asMap()
        .entries
        .where((entry) {
          final time = DateTime.parse(entry.value);
          return time.day == now.day && time.month == now.month && time.year == now.year;
        })
        .take(24)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Titre en haut de la page
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            city!,
            style: GoogleFonts.merriweather(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 199, 199, 199)
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Liste des prévisions horaires
        ...todayHours.map((entry) {
          final hourIndex = entry.key;
          final time = DateTime.parse(hourly['time'][hourIndex]);
          return Card(
            child: ListTile(
              title: Text(
                '${time.hour.toString().padLeft(2, '0')}:00',
                style: GoogleFonts.merriweather(),
              ),
              subtitle: Text(
                '${hourly['temperature_2m'][hourIndex]}°C - ${_getWeatherDescription(hourly['weather_code'][hourIndex])} - ${hourly['wind_speed_10m'][hourIndex]}km/h',
                style: GoogleFonts.merriweather(),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}