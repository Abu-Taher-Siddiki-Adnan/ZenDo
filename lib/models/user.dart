import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String? profileImagePath;

  @HiveField(3)
  DateTime joinDate;

  User({
    required this.name,
    required this.email,
    this.profileImagePath,
    DateTime? joinDate,
  }) : joinDate = joinDate ?? DateTime.now();

  String get welcomeMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, $name! ☀️';
    if (hour < 17) return 'Good afternoon, $name! 🌤';
    return 'Good evening, $name! 🌙';
  }
}