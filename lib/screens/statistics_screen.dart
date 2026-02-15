import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> moodStats = [];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final data = await DatabaseHelper().moodBreakdown();
    setState(() => moodStats = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),
      body: ListView(
        children: moodStats
            .map((e) => ListTile(
          title: Text("Mood: ${e['mood']}"),
          trailing: Text("Count: ${e['count']}"),
        ))
            .toList(),
      ),
    );
  }
}
