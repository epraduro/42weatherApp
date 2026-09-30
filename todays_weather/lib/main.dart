import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:open_meteo/open_meteo.dart';
import 'current_weather_tab.dart';
import 'weekly_weather_tab.dart';
import 'today_weather_tab.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Weather(),
    );
  }
}

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> with TickerProviderStateMixin {
  
  final Connectivity _connectivity = Connectivity();
  int _selectedIndex = 0;
  Map<String, dynamic>? _current;
  String region = "";
  String country = "";
  String lat = "";
  String long = "";
  Map<String, dynamic>? _weatherDataSearch;
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _cityController = TextEditingController();
  late TabController _mainTabController;
  late TabController _searchTabController;
  late TabController _locationTabController;
  String _resLocation = "";
  List<Map<String, dynamic>> _searchResults = [];
  final FocusNode _textFieldFocusNode = FocusNode();
  bool isFind = true;
  
  bool _isOffline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _searchTabController = TabController(length: 3, vsync: this);
    _locationTabController = TabController(length: 3, vsync: this);

    _searchTabController.addListener(() {
      if (!_searchTabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _searchTabController.index;
        });
      }
    });
    _locationTabController.addListener(() {
      if (!_locationTabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _locationTabController.index;
        });
      }
    });

    _checkConnectivity();

    _connectionSubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
       if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      } else {
        _updateConnectionStatus(ConnectivityResult.none);
      }
      }
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _mainTabController.dispose();
    _searchTabController.dispose();
    _locationTabController.dispose();
    _textFieldFocusNode.dispose();
    _connectionSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.isNotEmpty) {
        _updateConnectionStatus(result.first);
      } else {
        _updateConnectionStatus(ConnectivityResult.none);
      }
    } on PlatformException catch (e) {
      debugPrint('Erreur lors de la vérification de la connectivité : $e');
      setState(() {
        _isOffline = true;
      });
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    bool isOffline;

    switch (result) {
      case ConnectivityResult.wifi:
        isOffline = false;
        break;
      case ConnectivityResult.mobile:
        isOffline = false;
        break;
      case ConnectivityResult.none:
        isOffline = true;
        break;
      default:
        isOffline = true;
        break;
    }
    if (mounted) {
      setState(() {
        _isOffline = isOffline;
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _resLocation = "Les services de localisation sont désactivés. Veuillez les activer.";
      });
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      setState(() {
        _resLocation = "Geolocation is not available, please enable it in your App settings";
      });
      return;
    }

    try {
      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      setState(() {
        _resLocation = "${position.latitude} ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        print("Erreur lors de l'obtention de la localisation : $e");
      });
    }
  }

  String _formatLocation(Map<String, dynamic>? location) {
    if (location != null) {
      final name = location['name'] ?? '';
      final admin1 = location['admin1'] ?? '';
      final admin2 = location['country'] ?? '';
      return "$name${admin1.isNotEmpty ? ', $admin1' : ''}${admin2.isNotEmpty ? ', $admin2' : ''}";
    }
    return "";
  }

  Future<void> _fetchWeatherData() async {
    if (_isOffline) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Connexion Internet requise.";
      });
      return;
    }

    if (long.isEmpty || lat.isEmpty) {
      _current = {};
      _weatherDataSearch = {};
      isFind = false;
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long'
        '&current=temperature_2m,wind_speed_10m,weather_code'
        '&hourly=temperature_2m,weather_code,wind_speed_10m'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code'
        '&timezone=auto',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _weatherDataSearch = jsonDecode(response.body);
          _isLoading = false;
          isFind = true;
          lat = "";
          long = "";
        });
      } else {
        throw Exception('Erreur lors de la récupération des données météo');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (_isOffline) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      return;
    }
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _textFieldFocusNode.requestFocus();
    });

    try {
      final geocodingApi = GeocodingApi();
      final result = await geocodingApi.requestJson(name: query);

      if (result['results'] != null && result['results'].isNotEmpty) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(result['results']);
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
        _textFieldFocusNode.requestFocus();
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_mainTabController.index == 0) {
        _searchTabController.animateTo(index);
      } else {
        _locationTabController.animateTo(index);
      }
    });
  }

  List<TextSpan> _buildTextSpans(String fullText, String query, TextStyle defaultStyle, TextStyle boldStyle) {
    if (query.isEmpty) {
      return [TextSpan(text: fullText, style: defaultStyle)];
    }

    final List<TextSpan> spans = [];
    final String lowerFullText = fullText.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    int start = 0;

    while (start < fullText.length) {
      final int index = lowerFullText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: fullText.substring(start), style: defaultStyle));
        break;
      } else {
        if (index > start) {
          spans.add(TextSpan(text: fullText.substring(start, index), style: defaultStyle));
        }
        spans.add(TextSpan(text: fullText.substring(index, index + query.length), style: boldStyle));
        start = index + query.length;
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            flexibleSpace: TabBar(
              dividerColor: const Color.fromARGB(255, 0, 0, 0),
              padding: EdgeInsets.only(top: 40),
              labelPadding: EdgeInsets.zero,
              controller: _mainTabController,
              indicator: BoxDecoration(),
              tabs: [
                Tab(
                  height: 60,
                  child: TextField(
                      controller: _cityController,
                      focusNode: _textFieldFocusNode,
                      decoration: InputDecoration(
                        labelText: "Search location",
                        labelStyle: GoogleFonts.merriweather(
                          color: Colors.white
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color.fromARGB(255, 199, 199, 199),
                        ),
                      ),
                      enabled: !_isOffline,
                      onChanged: _isOffline 
                          ? null 
                          : (value) { 
                              _searchLocation(value); 
                            },
                      onSubmitted: _isOffline 
                          ? null 
                          : (value) {
                              _fetchWeatherData();
                            },
                      keyboardType: TextInputType.text,
                      cursorColor: Color.fromARGB(255, 199, 199, 199),
                      style: const TextStyle(color: Color.fromARGB(255, 199, 199, 199)),
                    ),
                  ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: AlwaysStoppedAnimation(90 / 360),
                        child: Icon(
                          Icons.remove,
                          color: Color.fromARGB(255, 199, 199, 199),
                          size: 50
                        ),
                      ),
                      TextButton(
                        onPressed: _isOffline
                            ? () {}
                            : _getLocation,
                        child: Icon(
                          Icons.near_me,
                          size: 25,
                          color: Color.fromARGB(255, 199, 199, 199),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "images/forest.webp"
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                TabBarView(
                  controller: _mainTabController,
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: TabBarView(
                            controller: _searchTabController,
                            children: [
                              CurrentWeatherTab(
                                weatherData: _weatherDataSearch,
                                city: _formatLocation(_current),
                                isLoading: _isLoading,
                                errorMessage: _errorMessage,
                                isOffline: _isOffline,
                                isFind: isFind,
                              ),
                              TodayWeatherTab(
                                weatherData: _weatherDataSearch,
                                city: _formatLocation(_current),
                                isLoading: _isLoading,
                                errorMessage: _errorMessage,
                              ),
                              WeeklyWeatherTab(
                                weatherData: _weatherDataSearch,
                                city: _formatLocation(_current),
                                isLoading: _isLoading,
                                errorMessage: _errorMessage,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              _resLocation,
                              style: GoogleFonts.merriweather(
                                fontSize: 18
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.black,
            child: BottomNavigationBar(
              backgroundColor: Colors.black,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.wb_sunny,
                    size: 15,
                    color: Color.fromARGB(255, 199, 199, 199),
                  ),
                  label: 'Current'
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.calendar_today,
                    size: 15,
                    color: Color.fromARGB(255, 199, 199, 199),
                  ),
                  label: 'Today',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.date_range,
                    size: 15,
                    color: Color.fromARGB(255, 199, 199, 199),
                  ),
                  label: 'Weekly',
                ),
              ],
              unselectedLabelStyle: GoogleFonts.merriweather(),
              selectedLabelStyle: GoogleFonts.merriweather(),
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Color.fromARGB(255, 199, 199, 199),
              onTap: _onItemTapped,
            ),
          ),
        ),
        if (_isOffline)
          Center(
            child: 
              Container(
                color: const Color.fromARGB(255, 133, 16, 8),
                padding: const EdgeInsets.all(50.0),
                child: Text(
                  'The service connection is lost, please check your internet connection or try again later',
                  style: GoogleFonts.merriweather(
                    color: Color.fromARGB(255, 199, 199, 199),
                    fontSize: 16,
                    decoration: TextDecoration.none
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ),
        if (!isFind)
          Center(
            child: 
              Container(
                color: const Color.fromARGB(255, 133, 16, 8),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Could not find any result for the supplied adresses',
                  style: GoogleFonts.merriweather(
                    color:  Color.fromARGB(255, 199, 199, 199),
                    fontSize: 16,
                    decoration: TextDecoration.none
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ),
        if (_searchResults.isNotEmpty || _isLoading)
          Positioned(
            left: 0,
            right: 0,
            top: kToolbarHeight * 2,
            child: Material(
              child: Container(
                color: Color.fromARGB(255, 199, 199, 199),
                height: MediaQuery.of(context).size.height,
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      if (index >= _searchResults.length) {
                        return const SizedBox.shrink();   // Empty widget to fill remaining slots
                      }
                      final location = _searchResults[index];
                      return ListTile(
                        leading: Icon(Icons.location_city_rounded),
                        title: RichText(
                          text: TextSpan(
                            style: GoogleFonts.merriweather(),
                            children: _buildTextSpans(
                              _formatLocation(location),
                              _cityController.text,
                              GoogleFonts.merriweather(
                                color: Colors.black
                              ),
                              GoogleFonts.merriweather(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        onTap: _isOffline
                          ? null
                          : () {
                            setState(() {
                              _cityController.text = _formatLocation(location);
                              _textFieldFocusNode.requestFocus();
                              _current = location;
                              long = location['longitude'].toString();
                              lat = location['latitude'].toString();
                              _searchResults = [];
                            });
                          },
                      );
                    },
                    separatorBuilder: (context, index) {
                      if (index < _searchResults.length - 1 && index < 4) {
                        return Divider(
                          thickness: 3,
                          color: Color.fromARGB(255, 199, 199, 199),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ),
            ),
          ),
      ],
    );
  }
}