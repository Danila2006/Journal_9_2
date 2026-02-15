import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/journal_entry.dart';
import 'entry_form_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'tags_management_screen.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<JournalEntry> entries = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    final data = searchQuery.isEmpty
        ? await DatabaseHelper().getEntries()
        : await DatabaseHelper().search(searchQuery);

    setState(() => entries = data);
  }

  void openEntryForm([JournalEntry? entry]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntryFormScreen(entry: entry),
      ),
    );
    loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal Timeline"),
        actions: [
          IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CalendarScreen()));
              }),
          IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()));
              }),
          IconButton(
              icon: const Icon(Icons.label),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TagsManagementScreen()));
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEntryForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                  hintText: "Search...", prefixIcon: Icon(Icons.search)),
              onChanged: (value) {
                searchQuery = value;
                loadEntries();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                return Card(
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text(
                        "${e.content.substring(0, e.content.length > 50 ? 50 : e.content.length)}..."),
                    trailing: Text(e.mood),
                    onTap: () => openEntryForm(e),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
