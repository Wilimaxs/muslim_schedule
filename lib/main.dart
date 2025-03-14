import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:muslim_schedule/features/dashboard/presentation/pages/navigation.dart';
import 'package:muslim_schedule/splash.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await initializeNotifications();
  runApp(const MyApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      // Ketika notifikasi diklik, hentikan musik
      stopAlarmSound();
    },
  );
}

final AudioPlayer audioPlayer = AudioPlayer();
bool isPlaying = false;

void scheduleAlarm(int id, DateTime dateTime) async {
  await AndroidAlarmManager.oneShotAt(
    dateTime,
    id,
    alarmCallback,
    exact: true,
    wakeup: true,
  );
}

Future<void> playAlarmSound() async {
  if (!isPlaying) {
    await audioPlayer.play(AssetSource('alarm.mp3')); 
    isPlaying = true;
  }
}

void alarmCallback() async {
  showNotification();
  playAlarmSound();
}



// Fungsi untuk menghentikan musik alarm
Future<void> stopAlarmSound() async {
  if (isPlaying) {
    await audioPlayer.stop();
    isPlaying = false;
  }
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'alarm_channel',
    'Alarm Notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('alarm_sound'),
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Alarm!',
    'Waktunya Sholat',
    platformChannelSpecifics,
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim Schedule',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      routes: {Navigation.routename: (context) => Navigation()},
    );
  }
}
