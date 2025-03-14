import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:muslim_schedule/features/alarm/domains/models/model_schedule.dart';
import 'package:audioplayers/audioplayers.dart'; // Tambahkan plugin audioplayers

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alarm Sholat")),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          return SwitchListTile(
            title: Text(schedules[index]["title"]),
            subtitle: Text("Waktu: ${schedules[index]["waktu"]}"),
            value: schedules[index]["status"],
            onChanged: (bool value) {
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
            },
          );
        },
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
        sound: RawResourceAndroidNotificationSound('onii_chan'),
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
    await audioPlayer.play(AssetSource('sounds/onii_chan.mp3'));
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
