import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:animated_analog_clock/animated_analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:muslim_schedule/features/alarm/domains/API/aladhan_api_sche.dart';
import 'package:muslim_schedule/features/alarm/domains/API/save_data.dart';
import 'package:muslim_schedule/features/alarm/domains/models/aladhan_model_alarm.dart';
import 'package:muslim_schedule/features/alarm/domains/models/model_schedule.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:muslim_schedule/features/alarm/presentation/widgets/shimmer_loading.dart'; // Tambahkan plugin audioplayers

final AudioPlayer audioPlayer = AudioPlayer();
bool isPlaying = false;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  bool isLoading = false;
  AladhanModelalarm? alarm;
  String lat = '';
  String long = '';
  bool wait = true;
  List<bool> statusList = [];

  @override
  void initState() {
    super.initState();
    initLocation();
  }

  final dbservice = DatabaseService();

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
      final apialadhanalarm = AladhanApialarm(baseUrl: baseUrl);
      final result = await apialadhanalarm.fetchapialarm();

      if (!mounted) return;
      //       List<bool> statusList = await Future.wait(
      //   schedules.map((schedule) => dbservice.readData(schedule['title']))
      // );

      for (var schedule in schedules) {
        bool status = await dbservice.readData(
          schedule['title'],
        ); // Accessing schedule['title']
        statusList.add(status);
      }

      setState(() {
        // schedules[0]['waktu'] = result.imsak;
        schedules[1]['waktu'] = result.shubuh;
        schedules[2]['waktu'] = result.dzuhur;
        schedules[3]['waktu'] = result.ashar;
        schedules[4]['waktu'] = result.maghrib;
        schedules[5]['waktu'] = result.isya;

        for (int i = 0; i < schedules.length; i++) {
          schedules[i]['status'] =
              statusList[i]; // ✅ Assign resolved Future<bool>
        }
        isLoading = false;
        wait = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        wait = false;
      });
    }
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
      return Future.error('tidak bisa membaca lokasi, karena ditolak');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> initLocation() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        lat = position.latitude.toString();
        long = position.longitude.toString();
      });
      fetchlocation();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Text('Alarm', style: Theme.of(context).textTheme.headlineLarge),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500), // Durasi animasi transisi
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child:
            wait
                ? ShimmerLoading()
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                        color: Colors.green.shade400,
                        child: Center(
                          child: Transform.scale(
                            scale: 0.9,
                            child: Container(
                              child: AnimatedAnalogClock(
                                backgroundImage: AssetImage(
                                  'assets/images/tobat_img_clock.png',
                                ),
                                dialType: DialType.numbers,
                                hourHandColor: Colors.lightBlueAccent,
                                minuteHandColor: Colors.lightBlueAccent,
                                secondHandColor: Colors.amber,
                                centerDotColor: Colors.amber,
                                hourDashColor: Colors.lightBlue,
                                minuteDashColor: Colors.blueAccent,
                                numberColor: Colors.purpleAccent.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Jadwal Hari ini',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      ListView.builder(
                        shrinkWrap: true,

                        itemCount: schedules.length,
                        itemBuilder: (context, index) {
                          return SwitchListTile(
                            title: Text(schedules[index]["title"]),
                            subtitle: Text(
                              "Waktu: ${schedules[index]["waktu"]}",
                            ),
                            value: schedules[index]["status"],
                            onChanged: (bool value) async {
                              setState(() {
                                schedules[index]["status"] = value;
                              });

                              if (value) {
                                scheduleAlarm(
                                  schedules[index]["id"],
                                  schedules[index]["waktu"],
                                );
                              } else {
                                cancelAlarm(schedules[index]["id"]);
                              }

                              try {
                                await dbservice.setDocumentWithMerge(
                                  schedules[index]["title"],
                                  schedules[index]["status"],
                                );
                                await dbservice.readData(
                                  schedules[index]["title"],
                                );
                              } catch (e) {
                                print("Failed to update database: $e");
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

// ✅ Fungsi untuk Menjadwalkan Alarm
void scheduleAlarm(int id, String waktu) async {
  DateTime now = DateTime.now();
  List<String> timeParts = waktu.split(":");
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  DateTime alarmTime = DateTime(now.year, now.month, now.day, hour, minute);
  if (alarmTime.isBefore(now)) {
    alarmTime = alarmTime.add(
      Duration(days: 1),
    ); // Jika sudah lewat, set ke besok
  }

  await AndroidAlarmManager.oneShotAt(
    alarmTime,
    id,
    alarmCallback,
    exact: true,
    wakeup: true,
  );

  print("Alarm dijadwalkan untuk ${alarmTime.toLocal()}");
}

// ✅ Callback ketika alarm berbunyi
@pragma('vm:entry-point')
void alarmCallback() async {
  showNotification();
  playAlarmSound();
}

// ✅ Notifikasi ketika alarm berbunyi
Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'alarm_channel',
        'Alarm Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alarm_2'),
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    'Alarm!',
    'Waktunya Sholat',
    platformChannelSpecifics,
  );
}

// ✅ Fungsi untuk Memainkan Suara Alarm
Future<void> playAlarmSound() async {
  if (!isPlaying) {
    await audioPlayer.play(AssetSource('sounds/alarm_2.mp3'));
    isPlaying = true;
  }
}

// ✅ Fungsi untuk Menghentikan Suara Alarm
Future<void> stopAlarmSound() async {
  if (isPlaying) {
    await audioPlayer.stop();
    isPlaying = false;
  }
}

// ✅ Fungsi untuk Membatalkan Alarm
void cancelAlarm(int id) async {
  await AndroidAlarmManager.cancel(id);
  print("Alarm dengan ID $id dibatalkan");
}
