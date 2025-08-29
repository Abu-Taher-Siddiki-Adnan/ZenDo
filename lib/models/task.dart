import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  bool hasAlarm;

  @HiveField(5)
  DateTime? alarmTime;

  @HiveField(6)
  String category;

  @HiveField(7)
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.hasAlarm = false,
    this.alarmTime,
    this.category = 'General',
    this.isCompleted = false,
  });
}