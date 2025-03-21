import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:muslim_schedule/features/dashboard/presentation/pages/navigation.dart';
import 'package:muslim_schedule/splash.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
    ),
  );
  await AndroidAlarmManager.initialize();
  await initializeNotifications();
  runApp(const MyApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) async {
      print("🔔 Notifikasi diklik! Payload: ${details.payload}");

      if (details.actionId == 'STOP_ALARM') {
        print("🛑 Tombol Stop Alarm ditekan!");
        await stopAlarmSound();
        await flutterLocalNotificationsPlugin.cancel(0); // Hapus notifikasi
      }
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
    await audioPlayer.play(AssetSource('alarm_2.mp3'));
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
    print("🔴 Menghentikan suara alarm...");
    await audioPlayer.stop();
    await audioPlayer.release();
    await audioPlayer.dispose();
    isPlaying = false;
    print("✅ Alarm berhenti.");
  } else {
    print("⚠️ Alarm sudah berhenti sebelumnya.");
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
    autoCancel: false, // Jangan otomatis hilang, biar user bisa stop manual
    sound: RawResourceAndroidNotificationSound('alarm_2'),
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'STOP_ALARM', // Unique action ID
        'Stop Alarm', // Teks tombol di notifikasi
        showsUserInterface: true, // Pastikan UI muncul
      ),
    ],
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
