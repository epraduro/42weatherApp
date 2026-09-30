import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:weather_icons/weather_icons.dart';

class TodayWeatherTab extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String? city;
  final bool isLoading;
  final String? errorMessage;

  TodayWeatherTab({
    this.weatherData,
    this.city,
    required this.isLoading,
    this.errorMessage,
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    if (weatherData == null) {
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
    final hourly = weatherData!['hourly'];
    final now = DateTime.now();
    final todayHours = hourly['time']
        .asMap()
        .entries
        .where((entry) {
          final time = DateTime.parse(entry.value);
          return time.day == now.day && time.month == now.month && time.year == now.year;
        })
        .map((entry) {
          final time = DateTime.parse(entry.value);
          // Normaliser à l'heure pleine
          return MapEntry(entry.key, DateTime(time.year, time.month, time.day, time.hour));
        })
        .take(24)
        .toList();
      
    return ListView(
      padding: const EdgeInsets.all(16.0),
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
        if (todayHours.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                color: const Color.fromARGB(172, 57, 57, 57),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1 * 3600 * 1000,
                          getTitlesWidget: (value, meta) {
                            final targetHours = [0, 3, 6, 9, 12, 15, 18, 21];
                            for (int targetHour in targetHours) {
                              final targetTime = DateTime(now.year, now.month, now.day, targetHour).millisecondsSinceEpoch;
                              if ((value.toInt() - targetTime).abs() < 60 * 1000) {
                                return Text(
                                  '$targetHour:00',
                                  style: GoogleFonts.merriweather(
                                    fontSize: 12, 
                                    color: Color.fromARGB(255, 199, 199, 199),
                                  ),
                                );
                              }
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}°C',
                            style: GoogleFonts.merriweather(
                              fontSize: 12,
                              color: Color.fromARGB(255, 199, 199, 199),
                            ),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List<FlSpot>.from(
                          todayHours.asMap().entries.map((entry) {
                            final hourIndex = entry.key;
                            final time = DateTime.parse(hourly['time'][hourIndex]).toLocal();
                            final normalizedTime = DateTime(time.year, time.month, time.day, time.hour);
                            final temp = hourly['temperature_2m'][hourIndex] is num
                                ? hourly['temperature_2m'][hourIndex].toDouble()
                                : double.tryParse(hourly['temperature_2m'][hourIndex].toString()) ?? 0.0;
                            return FlSpot(normalizedTime.millisecondsSinceEpoch.toDouble(), temp);
                          }),
                        ),
                        isCurved: true,
                        color: Color.fromARGB(255, 186, 131, 73),
                        dotData: FlDotData(
                          show: true,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color.fromARGB(0, 255, 255, 255)
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) => touchedSpots
                            .map((spot) => LineTooltipItem(
                                  '${spot.y.toStringAsFixed(1)}°C',
                                  GoogleFonts.merriweather(
                                    color: Color.fromARGB(255, 199, 199, 199),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    minX: DateTime(now.year, now.month, now.day, 0).millisecondsSinceEpoch.toDouble(),
                    maxX: DateTime(now.year, now.month, now.day, 23).millisecondsSinceEpoch.toDouble(),
                    minY: todayHours.isNotEmpty
                        ? (todayHours
                                .map((entry) => (hourly['temperature_2m'][entry.key] is num
                                    ? hourly['temperature_2m'][entry.key].toDouble()
                                    : double.tryParse(hourly['temperature_2m'][entry.key].toString()) ?? 0.0))
                                .reduce((a, b) => a < b ? a : b))
                            .floor()
                            .toDouble() - 2 
                        : 0.0,
                    maxY: todayHours.isNotEmpty
                        ? (todayHours
                                .map((entry) => (hourly['temperature_2m'][entry.key] is num
                                    ? hourly['temperature_2m'][entry.key].toDouble()
                                    : double.tryParse(hourly['temperature_2m'][entry.key].toString()) ?? 0.0))
                                .reduce((a, b) => a > b ? a : b))
                            .ceil()
                            .toDouble() + 2
                        : 10.0,
                  ),
                ),
              ),
            ),
          ),

    
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: todayHours.map<Widget>((entry) {
              final hourIndex = entry.key;
              final time = DateTime.parse(hourly['time'][hourIndex]);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 185,
                  width: 125,
                  child: Card(
                    color: const Color.fromARGB(172, 57, 57, 57),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 10),
                          Text(
                            '${time.hour.toString().padLeft(2, '0')}:00',
                            style: GoogleFonts.merriweather(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color.fromARGB(255, 199, 199, 199),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${hourly['temperature_2m'][hourIndex]}°C',
                            style: GoogleFonts.merriweather(
                              fontSize: 20,
                              color: Color.fromARGB(255, 186, 131, 73),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),
                          Icon(
                            weatherIcons[hourly['weather_code'][hourIndex]],
                            color: const Color.fromARGB(255, 7, 127, 225),
                            size: 30,
                          ),
                          SizedBox(height: 15),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 5,
                            children: [
                              Icon(
                                // weatherIcons[100],
                                Icons.air_rounded,
                                color: Color.fromARGB(255, 199, 199, 199),
                                size: 20,
                              ),
                              Text(
                                '${hourly['wind_speed_10m'][hourIndex]} km/h',
                                style: GoogleFonts.merriweather(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 199, 199, 199),
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}