import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ZenDo/models/task.dart';
import 'package:ZenDo/services/notification_service.dart';
import 'package:ZenDo/providers/tag_provider.dart';
import 'package:ZenDo/models/tag_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ZenDo/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:ZenDo/utils/responsive.dart';

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
  List<TagModel> tags = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.editTask != null) {
      titleController.text = widget.editTask!.title;
      descriptionController.text = widget.editTask!.description;
      dueDate = widget.editTask!.dueDate;
      hasAlarm = widget.editTask!.hasAlarm;
      alarmTime = widget.editTask!.alarmTime;
      selectedTag = widget.editTask!.category;
      isCompleted = widget.editTask!.isCompleted;
    }

    _loadTags();
  }

  void _loadTags() {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      setState(() {
        tags = List.from(tagProvider.tags);
      });
    } catch (e) {
      print('TagProvider not available: $e');
    }
  }

  int _generateSafeKey(Box<Task> box) {
    final existingKeys = box.keys.whereType<int>().toList();

    if (existingKeys.isEmpty) {
      return 1;
    }

    final maxKey = existingKeys.reduce((a, b) => a > b ? a : b);
    final newKey = maxKey + 1;

    if (newKey > 0xFFFFFFFF) {
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => dueDate = picked);
  }

  void _pickAlarmTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: alarmTime != null
          ? TimeOfDay.fromDateTime(alarmTime!)
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill in all required fields');
      return;
    }

    if (dueDate == null) {
      _showSnackBar('Please select a due date');
      return;
    }

    setState(() => _isSaving = true);

    try {
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

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error saving task: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDarkModeDialog =
            Theme.of(context).brightness == Brightness.dark;

        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              backgroundColor: isDarkModeDialog
                  ? Colors.grey[900]
                  : Colors.white,
              titleTextStyle: TextStyle(
                color: isDarkModeDialog ? Colors.white : Colors.black,
                fontSize: Responsive.textSize(20, context),
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: TextStyle(
                color: isDarkModeDialog ? Colors.white70 : Colors.black87,
                fontSize: Responsive.textSize(16, context),
              ),
            ),
          ),
          child: AlertDialog(
            title: Text(
              'Delete Task',
              style: TextStyle(
                color: isDarkModeDialog ? Colors.white : Colors.black,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this task? This action cannot be undone.',
              style: TextStyle(
                fontSize: Responsive.textSize(16, context),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDarkModeDialog ? Colors.white70 : Colors.blue,
                    fontSize: Responsive.textSize(16, context),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: Responsive.textSize(16, context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete == true) {
      try {
        final box = Hive.box<Task>('tasks');
        await box.delete(widget.editTask!.id);
        await NotificationService.cancelNotification(widget.editTask!.id);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Error deleting task: $e');
        }
      }
    }
  }

  void showAddTagDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogThemeData(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            titleTextStyle: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: Responsive.textSize(20, context),
              fontWeight: FontWeight.bold,
            ),
            contentTextStyle: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: Responsive.textSize(16, context),
            ),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                'Add New Category',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: Responsive.textSize(20, context),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: Responsive.textSize(16, context),
                      ),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[100],
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: Responsive.textSize(16, context),
                    ),
                  ),
                  SizedBox(height: Responsive.height(2, context)),
                  Row(
                    children: [
                      Text(
                        'Color:',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: Responsive.textSize(16, context),
                        ),
                      ),
                      SizedBox(width: Responsive.width(3, context)),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Theme(
                              data: Theme.of(context).copyWith(
                                dialogTheme: DialogThemeData(
                                  backgroundColor: isDarkMode
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  titleTextStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: Responsive.textSize(20, context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  contentTextStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontSize: Responsive.textSize(16, context),
                                  ),
                                ),
                              ),
                              child: AlertDialog(
                                title: Text(
                                  'Pick a Color',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: Responsive.textSize(20, context),
                                  ),
                                ),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: selectedColor,
                                    onColorChanged: (color) {
                                      setStateDialog(
                                        () => selectedColor = color,
                                      );
                                    },
                                    showLabel: true,
                                    pickerAreaHeightPercent: 0.8,
                                    portraitOnly: true,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'Select',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.blue,
                                        fontSize: Responsive.textSize(16, context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: Responsive.width(8, context),
                          height: Responsive.width(8, context),
                          decoration: BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white30
                                  : Colors.black26,
                              width: 2,
                            ),
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.blue,
                      fontSize: Responsive.textSize(16, context),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a category name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newTag = TagModel(
                      name: name,
                      colorValue: selectedColor.value,
                    );

                    try {
                      await Provider.of<TagProvider>(
                        context,
                        listen: false,
                      ).addTag(newTag);

                      _loadTags();

                      setState(() {
                        selectedTag = name;
                      });
                    } catch (e) {
                      print('Could not add tag through provider: $e');
                      setState(() {
                        tags = [...tags, newTag];
                        selectedTag = name;
                      });
                    }

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(fontSize: Responsive.textSize(16, context)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: AppTheme.cardGradientDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            widget.editTask != null ? "Edit Task" : "Add Task",
            style: TextStyle(fontSize: Responsive.textSize(18, context)),
          ),
          actions: widget.editTask != null
              ? [
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: Responsive.textSize(24, context),
                    ),
                    onPressed: _showDeleteConfirmation,
                    tooltip: 'Delete Task',
                  ),
                ]
              : null,
        ),
        body: Padding(
          padding: EdgeInsets.all(Responsive.width(4, context)),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.width(3, context),
                      ),
                    ),
                    filled: true,
                    fillColor: theme.cardColor.withOpacity(0.7),
                    labelStyle: TextStyle(
                      fontSize: Responsive.textSize(16, context),
                    ),
                  ),
                  style: TextStyle(fontSize: Responsive.textSize(16, context)),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a title' : null,
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                ),
                SizedBox(height: Responsive.height(2.5, context)),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.width(3, context),
                      ),
                    ),
                    filled: true,
                    fillColor: theme.cardColor.withOpacity(0.7),
                    labelStyle: TextStyle(
                      fontSize: Responsive.textSize(16, context),
                    ),
                  ),
                  style: TextStyle(fontSize: Responsive.textSize(16, context)),
                  maxLines: 3,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
                SizedBox(height: Responsive.height(2, context)),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.width(3, context),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      dueDate == null
                          ? 'Select Due Date *'
                          : 'Due: ${dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        color: dueDate == null
                            ? theme.hintColor
                            : theme.textTheme.bodyLarge?.color,
                        fontSize: Responsive.textSize(16, context),
                      ),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      size: Responsive.textSize(24, context),
                    ),
                    onTap: _pickDueDate,
                  ),
                ),
                SizedBox(height: Responsive.height(1, context)),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.width(3, context),
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'Set Reminder',
                      style: TextStyle(
                        fontSize: Responsive.textSize(16, context),
                      ),
                    ),
                    value: hasAlarm,
                    onChanged: (value) => setState(() {
                      hasAlarm = value;
                      if (!value) alarmTime = null;
                    }),
                  ),
                ),
                if (hasAlarm) ...[
                  SizedBox(height: Responsive.height(1, context)),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.width(3, context),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        alarmTime == null
                            ? 'Select Reminder Time'
                            : 'Reminder: ${alarmTime!.hour.toString().padLeft(2, '0')}:${alarmTime!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: alarmTime == null
                              ? theme.hintColor
                              : theme.textTheme.bodyLarge?.color,
                          fontSize: Responsive.textSize(16, context),
                        ),
                      ),
                      trailing: Icon(
                        Icons.access_alarm,
                        size: Responsive.textSize(24, context),
                      ),
                      onTap: _pickAlarmTime,
                    ),
                  ),
                ],
                if (widget.editTask != null) ...[
                  SizedBox(height: Responsive.height(1, context)),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.width(3, context),
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: Responsive.textSize(16, context),
                        ),
                      ),
                      value: isCompleted,
                      onChanged: (value) => setState(() => isCompleted = value),
                    ),
                  ),
                ],
                SizedBox(height: Responsive.height(2, context)),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.width(3, context),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width(4, context),
                      vertical: Responsive.height(1, context),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedTag,
                      hint: Text(
                        'Select Category',
                        style: TextStyle(
                          fontSize: Responsive.textSize(16, context),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'General',
                          child: Text(
                            'General',
                            style: TextStyle(
                              fontSize: Responsive.textSize(16, context),
                            ),
                          ),
                        ),
                        ...tags.map((tag) {
                          return DropdownMenuItem(
                            value: tag.name,
                            child: Row(
                              children: [
                                Container(
                                  width: Responsive.width(4, context),
                                  height: Responsive.width(4, context),
                                  margin: EdgeInsets.only(
                                    right: Responsive.width(3, context),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(tag.colorValue),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black26,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                Text(
                                  tag.name,
                                  style: TextStyle(
                                    fontSize: Responsive.textSize(16, context),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) => setState(() => selectedTag = value),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Category',
                        labelStyle: TextStyle(
                          fontSize: Responsive.textSize(16, context),
                        ),
                      ),
                      isExpanded: true,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.height(1, context)),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.width(3, context),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => showAddTagDialog(context),
                    borderRadius: BorderRadius.circular(
                      Responsive.width(3, context),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.width(4, context),
                        vertical: Responsive.height(2, context),
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(
                          Responsive.width(3, context),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: Responsive.textSize(18, context),
                            color: theme.primaryColor,
                          ),
                          SizedBox(width: Responsive.width(2, context)),
                          Text(
                            'Add New Category',
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: Responsive.textSize(16, context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.height(3, context)),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.height(2, context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.width(3, context),
                      ),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: Responsive.width(5, context),
                          height: Responsive.width(5, context),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          widget.editTask != null ? "Update Task" : "Save Task",
                          style: TextStyle(
                            fontSize: Responsive.textSize(16, context),
                          ),
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