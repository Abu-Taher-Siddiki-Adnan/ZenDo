import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ZenDo/models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ZenDo/models/user.dart';
import 'package:ZenDo/screens/home_screen.dart';
import 'package:ZenDo/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:ZenDo/providers/theme_provider.dart';
import 'package:ZenDo/providers/tag_provider.dart';
import 'package:ZenDo/models/tag_model.dart';
import 'package:ZenDo/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService.init();

    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);

    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(TagModelAdapter());

    await Hive.openBox<Task>('tasks');
    await Hive.openBox<User>('user');
    await Hive.openBox<TagModel>('tags');

    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()..setTheme(isDark)),
          ChangeNotifierProvider(create: (_) => TagProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: Text('Failed to initialize app: $e')),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: "TaskFlow",
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}