import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muslim_schedule/features/calender/domains/api/data_calender.dart';
import 'package:muslim_schedule/features/calender/presentation/pages/event.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  DateTime today = DateTime.now();
  DateTime? selectedDay;
  Map<DateTime, List<Event>> events = {};
  TextEditingController eventController = TextEditingController();
  late final ValueNotifier<List<Event>> selectedEvents;

  final dbservice = databasecalender();

@override
void initState() {
  super.initState();
  selectedDay = today;
  selectedEvents = ValueNotifier(getEventsForDay(selectedDay!));
  
  // Load events from Firebase
  loadEventsFromFirebase();
}

Future<void> loadEventsFromFirebase() async {
  final dbservice = databasecalender();
  final eventsList = await dbservice.getdata();
  
  setState(() {
    events.clear();
    for (var eventData in eventsList) {
      final title = eventData['title'] as String;
      
      // Handle Firestore Timestamp conversion
      final Timestamp timestamp = eventData['tanggal'] as Timestamp;
      final DateTime eventDate = timestamp.toDate();
      final dateOnly = DateUtils.dateOnly(eventDate);
      
      if (!events.containsKey(dateOnly)) {
        events[dateOnly] = [];
      }
      
      events[dateOnly]!.add(Event(title, getRandomColor()));
    }
  });
  
  // Update the selected events
  if (selectedDay != null) {
    selectedEvents.value = getEventsForDay(selectedDay!);
  }
}

  List<Event> getEventsForDay(DateTime day) {
    return events[DateUtils.dateOnly(day)] ?? [];
  }

  void _onChangeday(DateTime day, DateTime focusedDay) {
    setState(() {
      selectedDay = DateUtils.dateOnly(day);
    });
    selectedEvents.value = getEventsForDay(selectedDay!);
  }

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Kalender',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Masukan Acara'),
                content: TextField(
                  controller: eventController,
                  keyboardType: TextInputType.text,
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      if (selectedDay != null &&
                          eventController.text.isNotEmpty) {
                        DateTime eventDate = DateUtils.dateOnly(selectedDay!);

                        if (!events.containsKey(eventDate)) {
                          events[eventDate] = [];
                        }
                        events[eventDate]!.add(
                          Event(eventController.text, getRandomColor()),
                        );
                        dbservice.create(eventController.text, eventDate);

                        eventController.clear();
                        Navigator.of(context).pop();
                        selectedEvents.value = getEventsForDay(selectedDay!);
                      }
                    },
                    child: Text('Tambah'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: "en_US",
            rowHeight: 43,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            eventLoader: getEventsForDay,
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: today,
            onDaySelected: _onChangeday,
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: value[index].color, // Apply random color
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          value[index].title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
