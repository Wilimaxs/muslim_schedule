import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:muslim_schedule/features/dashboard/domains/api/aladhan_api.dart';
import 'package:muslim_schedule/features/dashboard/domains/api/aladhan_watch.dart';
import 'package:muslim_schedule/features/dashboard/domains/models/aladhan_model.dart';
import 'package:muslim_schedule/features/dashboard/domains/models/aladhan_modelwatch.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String lat = '';
  String long = '';
  String locationText = "Pilih Lokasi";
  bool isLoading = false;
  Map<String, dynamic>? prayerTimes;
  AladhanModel? schedule;
  AladhanModelday? aladay;

  Future<void> fetchlocation() async {
    if (!mounted) return;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat(
      "yy-MM-dd",
    ).format(now); // Format the date
    setState(() {
      isLoading = true;
    });

    try {
      String baseUrl =
          'https://api.aladhan.com/v1/timings/$formattedDate?latitude=$lat&longitude=$long&method=20';
      final apialadhan = AladhanApi(baseUrl: baseUrl);
      final apialadhanday = AladhanApiday(baseUrl: baseUrl);
      final result = await apialadhan.fetchapi();
      final resultDay = await apialadhanday.fetchapiwatch();

      if (!mounted) return;

      setState(() {
        schedule = result;
        aladay = resultDay;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openMap(String lat, String long) async {
    String googleURL =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    await canLaunchUrlString(googleURL)
        ? await launchUrlString(googleURL)
        : throw 'tidak bisa buka $googleURL';
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      return Future.error('Izinkan membaca lokasi');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('izin Permisi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('tidak bisa membaca lokasi, karena ditolok');
    }

    return await Geolocator.getCurrentPosition();
  }

  void liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 500,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((
      Position position,
    ) {
      setState(() {
        // 👈 Make sure the UI updates
        lat = position.latitude.toString();
        long = position.longitude.toString();
      });
    });
  }

  Future<void> getAddressFromLatLng(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];

      setState(() {
        locationText =
            "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    initLocation();
  }

  Future<void> initLocation() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        lat = position.latitude.toString();
        long = position.longitude.toString();
      });

      await getAddressFromLatLng(position.latitude, position.longitude);
      fetchlocation();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool running = true;
    Stream<String> clock() async* {
      // This loop will run forever because _running is always true
      while (running) {
        await Future<void>.delayed(const Duration(seconds: 1));
        DateTime now = DateTime.now();
        // This will be displayed on the screen as current time
        yield "${now.hour} : ${now.minute} : ${now.second}";
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.35,
              color: Colors.green.shade400,
              child: Center(
                child: Transform.scale(
                  scale: 11.0,
                  child: Opacity(
                    opacity: 0.50,
                    child: Container(
                      child: Lottie.asset(
                        'assets/lottie/Animation_home.json',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.amber, size: 35),
                    Expanded(
                      child: Text(
                        locationText, // Address from geocoding
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow:
                            TextOverflow
                                .ellipsis, // Add ellipsis (...) for long text
                        maxLines: 1, // Limit to 1 line
                        softWrap: false, // Prevents wrapping to new line
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: MediaQuery.of(context).size.width,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Maghrib',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreamBuilder(
                          stream: clock(),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            return Text(
                              snapshot.data!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            );
                          },
                        ),
                        SizedBox(width: 20),
                        Text('|', style: Theme.of(context).textTheme.bodyLarge),
                        SizedBox(width: 20),
                        Text(
                          schedule?.maghrib != null
                              ? '${schedule?.maghrib}.00'
                              : 'Loading...',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Jadwal Hari ini',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('No')),
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Hari')),
                DataColumn(label: Text('Waktu')),
              ],
              rows: <DataRow>[
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('1')),
                    DataCell(Text('Imsak')),
                    DataCell(Text(aladay?.day ?? 'loading...')),
                    DataCell(Text(schedule?.imsak ?? 'Loading...')),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('2')),
                    DataCell(Text('Shubuh')),
                    DataCell(Text(aladay?.day ?? 'loading...')),
                    DataCell(Text(schedule?.shubuh ?? 'Loading...')),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('3')),
                    DataCell(Text('Dzuhur')),
                    DataCell(Text(aladay?.day ?? 'loading...')),
                    DataCell(Text(schedule?.dzuhur ?? 'Loading...')),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('4')),
                    DataCell(Text('Ashar')),
                    DataCell(Text(aladay?.day ?? 'loading...')),
                    DataCell(Text(schedule?.ashar ?? 'Loading...')),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('5')),
                    DataCell(Text('Maghrib')),
                    DataCell(Text(aladay?.day ?? 'loading...')),
                    DataCell(Text(schedule?.maghrib ?? 'Loading...')),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('6')),
                    DataCell(Text('Isya')),
                    DataCell(Text(aladay?.day ?? 'loading...')),
                    DataCell(Text(schedule?.isya ?? 'Loading...')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
