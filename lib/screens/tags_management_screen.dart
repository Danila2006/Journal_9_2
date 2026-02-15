import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tag.dart';

class TagsManagementScreen extends StatefulWidget {
  const TagsManagementScreen({super.key});

  @override
  State<TagsManagementScreen> createState() =>
      _TagsManagementScreenState();
}

class _TagsManagementScreenState extends State<TagsManagementScreen> {
  List<Tag> tags = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTags();
  }

  Future<void> loadTags() async {
    final data = await DatabaseHelper().getTags();
    setState(() => tags = data);
  }

  void addTag() async {
    if (controller.text.isEmpty) return;

    await DatabaseHelper().insertTag(Tag(
      name: controller.text,
      color: "#2196F3",
      createdAt: DateTime.now(),
    ));

    controller.clear();
    loadTags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tags")),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "New tag"),
                ),
              ),
              IconButton(onPressed: addTag, icon: const Icon(Icons.add))
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tags.length,
              itemBuilder: (_, i) {
                final tag = tags[i];
                return ListTile(
                  title: Text(tag.name),
                  subtitle: Text(tag.color),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
