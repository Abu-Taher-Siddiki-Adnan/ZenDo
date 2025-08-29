import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ZenDo/models/task.dart';
import 'package:ZenDo/services/notification_service.dart';
import 'package:ZenDo/providers/tag_provider.dart';
import 'package:ZenDo/models/tag_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ZenDo/theme/app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? editTask;

  const AddTaskScreen({super.key, this.editTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? dueDate;
  bool hasAlarm = false;
  DateTime? alarmTime;
  String? selectedTag;
  bool isCompleted = false;
  List<TagModel> tags = []; // Store tags locally

  @override
  void initState() {
    super.initState();

    // Pre-fill fields if editing an existing task
    if (widget.editTask != null) {
      titleController.text = widget.editTask!.title;
      descriptionController.text = widget.editTask!.description;
      dueDate = widget.editTask!.dueDate;
      hasAlarm = widget.editTask!.hasAlarm;
      alarmTime = widget.editTask!.alarmTime;
      selectedTag = widget.editTask!.category;
      isCompleted = widget.editTask!.isCompleted;
    }

    // Load tags when the screen initializes
    _loadTags();
  }

  // Method to load tags safely
  void _loadTags() {
    try {
      // Try to get TagProvider from context
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      setState(() {
        tags = tagProvider.tags;
      });
    } catch (e) {
      // If provider is not available, use an empty list
      print('TagProvider not available: $e');
      tags = [];
    }
  }

  // Helper method to generate a safe key within Hive's range
  int _generateSafeKey(Box<Task> box) {
    // Get all existing integer keys
    final existingKeys = box.keys.whereType<int>().toList();
    
    if (existingKeys.isEmpty) {
      return 1; // Start from 1
    }
    
    // Find the maximum key
    final maxKey = existingKeys.reduce((a, b) => a > b ? a : b);
    final newKey = maxKey + 1;
    
    // Ensure the key is within Hive's valid range (0 - 0xFFFFFFFF)
    if (newKey > 0xFFFFFFFF) {
      // If we exceed the maximum, find the first available key
      for (int i = 1; i <= 0xFFFFFFFF; i++) {
        if (!box.containsKey(i)) {
          return i;
        }
      }
      throw Exception('No available keys in Hive box');
    }
    
    return newKey;
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => dueDate = picked);
  }

  void _pickAlarmTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: alarmTime != null
          ? TimeOfDay.fromDateTime(alarmTime!)
          : TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        alarmTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate() || dueDate == null) return;

    final box = Hive.box<Task>('tasks');
    
    int taskId;
    if (widget.editTask != null) {
      taskId = widget.editTask!.id;
    } else {
      taskId = _generateSafeKey(box);
    }

    final newTask = Task(
      id: taskId,
      title: titleController.text,
      description: descriptionController.text,
      dueDate: dueDate!,
      hasAlarm: hasAlarm,
      alarmTime: alarmTime,
      category: selectedTag ?? 'General',
      isCompleted: isCompleted,
    );

    await box.put(taskId, newTask);

    if (widget.editTask != null) {
      await NotificationService.cancelNotification(widget.editTask!.id);
    }

    if (hasAlarm && alarmTime != null && alarmTime!.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: taskId,
        title: 'Task Reminder: ${newTask.title}',
        body: newTask.description.isNotEmpty
            ? newTask.description
            : 'Due on ${dueDate!.toString().split(' ')[0]}',
        scheduledTime: alarmTime!,
      );
    }

    Navigator.pop(context);
  }

  void showAddTagDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Tag'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tag Name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Color:'),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Pick a Color'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: selectedColor,
                                onColorChanged: (color) {
                                  setState(() => selectedColor = color);
                                },
                                showLabel: true,
                                pickerAreaHeightPercent: 0.8,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Select'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    final newTag = TagModel(
                      name: name,
                      colorValue: selectedColor.value,
                    );
                    
                    try {
                      Provider.of<TagProvider>(context, listen: false).addTag(newTag);
                     
                      setState(() {
                        tags = [...tags, newTag];
                      });
                    } catch (e) {
                      print('Could not add tag through provider: $e');
                      
                      setState(() {
                        tags = [...tags, newTag];
                      });
                    }
                    
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardGradientDecoration,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.editTask != null ? "Edit Task" : "Add Task"),
        actions: widget.editTask != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final shouldDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      final box = Hive.box<Task>('tasks');
                      await box.delete(widget.editTask!.id);
                      await NotificationService.cancelNotification(
                        widget.editTask!.id,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  dueDate == null
                      ? 'Select Due Date'
                      : 'Due: ${dueDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              SwitchListTile(
                title: const Text('Set Alarm'),
                value: hasAlarm,
                onChanged: (value) => setState(() {
                  hasAlarm = value;
                  if (!value) alarmTime = null;
                }),
              ),
              if (hasAlarm)
                ListTile(
                  title: Text(
                    alarmTime == null
                        ? 'Select Alarm Time'
                        : 'Alarm: ${alarmTime!.hour.toString().padLeft(2, '0')}:${alarmTime!.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_alarm),
                  onTap: _pickAlarmTime,
                ),
              if (widget.editTask != null)
                SwitchListTile(
                  title: const Text('Completed'),
                  value: isCompleted,
                  onChanged: (value) => setState(() => isCompleted = value),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTag,
                hint: const Text('Select Category'),
                items: [
                  const DropdownMenuItem(
                    value: 'General',
                    child: Text('General'),
                  ),
                  ...tags.map((tag) {
                    return DropdownMenuItem(
                      value: tag.name,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Color(tag.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(tag.name),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) => setState(() => selectedTag = value),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => showAddTagDialog(context),
                child: const Text('+ Add Tag',style: TextStyle(color: Colors.black),),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(
                  widget.editTask != null ? "Update Task" : "Save Task",
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}