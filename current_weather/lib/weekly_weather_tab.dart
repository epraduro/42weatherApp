import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyWeatherTab extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String? city;
  final bool isLoading;
  final String? errorMessage;

  const WeeklyWeatherTab({
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
      case 95:
        return 'Slight or moderate thunderstorm';
      case 96:
      case 99:
        return 'Slight thunderstorm and heavy hail';
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

    final daily = weatherData!['daily'];
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            city!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 199, 199, 199)
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Liste des prévisions
        ...List.generate(
          daily['time'].length,
          (index) {
            final date = DateTime.parse(daily['time'][index]);
            return Card(
              child: ListTile(
                title: Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: GoogleFonts.merriweather(),
                ),
                subtitle: Text(
                  '${daily['temperature_2m_max'][index]}°C ${daily['temperature_2m_min'][index]}°C - ${_getWeatherDescription(daily['weather_code'][index])}',
                  style: GoogleFonts.merriweather(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}