import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<String, int> entriesPerDay = {};

  @override
  void initState() {
    super.initState();
    loadCalendar();
  }

  Future<void> loadCalendar() async {
    final data = await DatabaseHelper().getEntries();

    Map<String, int> map = {};
    for (var e in data) {
      final key = e.createdAt.toIso8601String().substring(0, 10);
      map[key] = (map[key] ?? 0) + 1;
    }

    setState(() => entriesPerDay = map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: ListView(
        children: entriesPerDay.entries
            .map((e) => ListTile(
          title: Text(e.key),
          trailing: Text("${e.value} entries"),
        ))
            .toList(),
      ),
    );
  }
}
