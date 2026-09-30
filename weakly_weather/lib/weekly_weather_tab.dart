import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:weather_icons/weather_icons.dart';

class WeeklyWeatherTab extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String? city;
  final bool isLoading;
  final String? errorMessage;

  WeeklyWeatherTab({
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
    final daily = weatherData!['daily'];
    final now = DateTime.now();

    final weekDays = daily['time']
        .asMap()
        .entries
        .where((entry) {
          final time = DateTime.parse(entry.value);
          final difference = time.difference(now).inDays;
          return difference >= 0 && difference < 7;
        })
        .map((entry) {
          final time = DateTime.parse(entry.value);
          return MapEntry(entry.key, DateTime(time.year, time.month, time.day));
        })
        .toList();

    final minX = DateTime(now.year, now.month, now.day - 1, 0).millisecondsSinceEpoch.toDouble();
    final maxX = DateTime(now.year, now.month, now.day + 7, 0).millisecondsSinceEpoch.toDouble();

    final minY = 0.0;
    final maxY = 50.0;

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
                  color: const Color.fromARGB(255, 186, 131, 73),
                ),
              ),
              TextSpan(
                text: "$region\n$country\n",
                style: GoogleFonts.merriweather(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 199, 199, 199),
                ),
              ),
            ],
          ),
        ),
        if (weekDays.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: const Color.fromARGB(172, 57, 57, 57),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: 
                  LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 24 * 3600 * 1000,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                              final normalizedDate = DateTime(date.year, date.month, date.day);
                              final matchingDay = weekDays.firstWhere(
                                (entry) => entry.value == normalizedDate,
                                orElse: () => MapEntry(-1, DateTime(0)),
                              );
                              if (matchingDay.key != -1) {
                                return Text(
                                  '${normalizedDate.day}/${normalizedDate.month}',
                                  style: GoogleFonts.merriweather(
                                    fontSize: 12,
                                    color: const Color.fromARGB(255, 199, 199, 199),
                                  ),
                                );
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
                                color: const Color.fromARGB(255, 199, 199, 199),
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
                            weekDays.asMap().entries.map((entry) {
                              final dayIndex = entry.key;
                              final time = entry.value;
                              final temp = daily['temperature_2m_max'][dayIndex] is num
                                  ? daily['temperature_2m_max'][dayIndex].toDouble()
                                  : double.tryParse(daily['temperature_2m_max'][dayIndex].toString()) ?? 0.0;
                              return FlSpot(time.value.millisecondsSinceEpoch.toDouble(), temp);
                            }),
                          ),
                          isCurved: true,
                          color: const Color.fromARGB(255, 186, 131, 73),
                          dotData: FlDotData(
                            show: true,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color.fromARGB(0, 255, 255, 255),
                          ),
                        ),
                        LineChartBarData(
                          spots: List<FlSpot>.from(
                            weekDays.asMap().entries.map((entry) {
                              final dayIndex = entry.key;
                              final time = entry.value;
                              final temp = daily['temperature_2m_min'][dayIndex] is num
                                  ? daily['temperature_2m_min'][dayIndex].toDouble()
                                  : double.tryParse(daily['temperature_2m_min'][dayIndex].toString()) ?? 0.0;
                              return FlSpot(time.value.millisecondsSinceEpoch.toDouble(), temp);
                            }),
                          ),
                          isCurved: true,
                          color: Color.fromARGB(255, 31, 110, 50),
                          dotData: FlDotData(
                            show: true,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color.fromARGB(0, 255, 255, 255),
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
                                      color: const Color.fromARGB(255, 199, 199, 199),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      minX: minX,
                      maxX: maxX,
                      minY: minY,
                      maxY: maxY,
                    ),
                  ),
                ),
              ),
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(color: Color.fromARGB(255, 186, 131, 73), text: "max temp"),
            SizedBox(height: 16),
            _buildLegendItem(color: Color.fromARGB(255, 31, 110, 50), text: "min temp")
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: weekDays.map<Widget>((entry) {
              final days = entry.key;
              final date = DateTime.parse(daily['time'][days]);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 190,
                  width: 145,
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
                            '${date.day}/${date.month}',
                            style: GoogleFonts.merriweather(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color.fromARGB(255, 199, 199, 199),
                            ),
                          ),
                          SizedBox(height: 15),
                          Icon(
                            weatherIcons[daily['weather_code'][days]],
                            color: const Color.fromARGB(255, 7, 127, 225),
                            size: 30,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${daily['temperature_2m_max'][days]}°C max',
                            style: GoogleFonts.merriweather(
                              fontSize: 20,
                              color: Color.fromARGB(255, 186, 131, 73),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${daily['temperature_2m_min'][days]}°C min',
                            style: GoogleFonts.merriweather(
                              fontSize: 20,
                              color:  Color.fromARGB(255, 31, 110, 50),
                              fontWeight: FontWeight.bold,
                            ),
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

Widget _buildLegendItem({required Color color, required String text}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color.fromARGB(172, 57, 57, 57), 
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.linear_scale,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}