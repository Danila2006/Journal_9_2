import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/journal_entry.dart';
import '../utils/word_count.dart';

class EntryFormScreen extends StatefulWidget {
  final JournalEntry? entry;

  const EntryFormScreen({super.key, this.entry});

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String mood = "🙂";

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      mood = widget.entry!.mood;
    }
  }

  void saveEntry() async {
    final now = DateTime.now();

    final entry = JournalEntry(
      id: widget.entry?.id,
      title: _titleController.text,
      content: _contentController.text,
      mood: mood,
      createdAt: widget.entry?.createdAt ?? now,
      updatedAt: now,
      isFavorite: false,
      wordCount: calculateWordCount(_contentController.text),
    );

    if (widget.entry == null) {
      await DatabaseHelper().insertEntry(entry);
    } else {
      await DatabaseHelper().updateEntry(entry);
    }

    Navigator.pop(context);
  }

  void deleteEntry() async {
    if (widget.entry != null) {
      await DatabaseHelper().deleteEntry(widget.entry!.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entry")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "Content"),
            ),
            DropdownButton<String>(
              value: mood,
              items: ["🙂", "😐", "😢", "😡"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => mood = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveEntry, child: const Text("Save")),
            if (widget.entry != null)
              TextButton(
                  onPressed: deleteEntry,
                  child: const Text("Delete",
                      style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
