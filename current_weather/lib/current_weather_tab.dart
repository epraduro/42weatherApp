import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';

class CurrentWeatherTab extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String? city;
  final bool isLoading;
  final String? errorMessage;
  final bool isOffline;
  final bool isFind;

  CurrentWeatherTab({
    this.weatherData,
    this.city,
    required this.isLoading,
    this.errorMessage,
    required this.isOffline,
    required this.isFind,
    super.key,
  });

  final Map<int, IconData> weatherIcons = {
    0: WeatherIcons.day_sunny,
    1: WeatherIcons.day_sunny_overcast,
    2: WeatherIcons.day_cloudy,
    3: WeatherIcons.cloudy,
    45: WeatherIcons.fog,
    48: WeatherIcons.fog,
    51: WeatherIcons.day_rain_mix,
    53: WeatherIcons.rain_mix,
    55: WeatherIcons.rain,
    56: WeatherIcons.day_sleet,
    57: WeatherIcons.sleet,
    61: WeatherIcons.day_rain,
    63: WeatherIcons.rain,
    65: WeatherIcons.rain_wind,
    66: WeatherIcons.day_sleet,
    67: WeatherIcons.sleet,
    71: WeatherIcons.day_snow,
    73: WeatherIcons.snow,
    75: WeatherIcons.snow_wind,
    77: WeatherIcons.snowflake_cold,
    80: WeatherIcons.day_showers,
    81: WeatherIcons.showers,
    82: WeatherIcons.storm_showers,
    85: WeatherIcons.day_snow,
    86: WeatherIcons.snow_wind,
    100: WeatherIcons.windy,
  };

  String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear sky\n';
      case 1:
        return 'Mainly clear\n';
      case 2:
        return 'Partly cloudy\n';
      case 3:
        return 'Overcast\n';
      case 45:
        return 'Fog\n';
      case 48:
        return 'Depositing rime fog\n';
      case 51:
        return 'Light drizzle\n';
      case 53:
        return 'Moderate drizzle\n';
      case 55:
        return 'Dense intensity drizzle\n';
      case 56:
        return 'Light freezing drizzle\n';
      case 57:
        return 'Dense intensity freezing drizzle\n';
      case 61:
        return 'Slight rain\n';
      case 63:
        return 'Moderate rain\n';
      case 65:
        return 'Heavy intensity rain\n';
      case 66: 
        return 'Light freezing rain\n';
      case 67:
        return 'Heavy intensity freezing rain\n';
      case 71:
        return 'Slight snow fall\n';
      case 73:
        return 'Moderate snow fall\n';
      case 75:
        return 'Heavy intensity snow fall\n';
      case 77:
        return 'Snow grains\n';
      case 80:
        return 'Slight rain showers\n';
      case 81:
        return 'Moderate rain showers\n';
      case 82:
        return 'Violent rain showers\n';
      case 85:
        return 'Slight snow showers\n';
      case 86:
        return 'Heavy snow showers\n';
      default:
        return 'Inconnu\n';
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

    List<String> cityParts = city!.split(', ');
    String cityName = cityParts.isNotEmpty ? cityParts[0] : 'Inconnue';
    String region = cityParts.length > 1 ? cityParts[1] : '';
    String country = cityParts.length > 2 ? cityParts[2] : '';

    final current = weatherData!['current'];
    return Center( 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$cityName\n",
                  style: GoogleFonts.merriweather(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 186, 131, 73),
                  ),
                ),
                TextSpan(
                  text: "$region\n$country\n",
                  style: GoogleFonts.merriweather(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 199, 199, 199), 
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${current['temperature_2m']}°C\n',
            style: GoogleFonts.merriweather(
              fontSize: 30,
              color: Color.fromARGB(255, 186, 131, 73)
            )
          ),
          Text(
            _getWeatherDescription(current['weather_code']),
            style: GoogleFonts.merriweather(
              fontSize: 25,
              color: Color.fromARGB(255, 199, 199, 199),
            )
          ),
          Icon(
            weatherIcons[current['weather_code']],
            color: const Color.fromARGB(255, 13, 109, 188),
            size: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Icon(
                // weatherIcons[100],
                Icons.air_rounded,
                color: Color.fromARGB(255, 199, 199, 199),
                size: 30,
              ),
              Text(
                '\n${current['wind_speed_10m']}km/h\n',
                style: GoogleFonts.merriweather(
                  fontSize: 20,
                  color: Color.fromARGB(255, 199, 199, 199),
                )
              )
            ],
          ),
        ],
      ),
    );
  }
}