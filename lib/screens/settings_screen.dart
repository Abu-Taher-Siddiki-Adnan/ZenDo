import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ZenDo/providers/theme_provider.dart';
import 'package:ZenDo/providers/tag_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ZenDo/models/task.dart';
import 'package:ZenDo/theme/app_theme.dart';
import 'developer_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Container(
      decoration: AppTheme.gradientBoxDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Settings", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          children: [
            // Profile Section
            _buildSectionHeader("YOUR PROFILE", context),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // CHANGED: Black in dark mode, white in light mode
              color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.person, color: AppTheme.primaryCyan),
                title: Text(
                  "Your Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  "Update your personal information",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ),

            // Appearance Section
            _buildSectionHeader("APPEARANCE", context),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // CHANGED: Black in dark mode, white in light mode
              color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.dark_mode, color: AppTheme.primaryCyan),
                title: Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeProvider>().setTheme(value);
                  },
                  activeColor: AppTheme.primaryCyan,
                ),
              ),
            ),

            // Data Management Section
            _buildSectionHeader("DATA MANAGEMENT", context),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // CHANGED: Black in dark mode, white in light mode
              color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.delete_sweep,
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                    ),
                    title: Text(
                      "Clear All Tasks",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "Permanently delete all tasks",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    trailing: Icon(
                      Icons.warning,
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                    ),
                    onTap: () async {
                      final confirmed = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Clear All Tasks"),
                          content: const Text(
                            "Are you sure you want to delete all tasks? This action cannot be undone.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "Delete All",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        final taskBox = Hive.box<Task>('tasks');
                        await taskBox.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("All tasks have been deleted"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.label_off,
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                    ),
                    title: Text(
                      "Clear All Tags",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "Permanently delete all tags",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    trailing: Icon(
                      Icons.warning,
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                    ),
                    onTap: () async {
                      final confirmed = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Clear All Tags"),
                          content: const Text(
                            "Are you sure you want to delete all tags? This action cannot be undone.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "Delete All",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        final tagProvider = Provider.of<TagProvider>(
                          context,
                          listen: false,
                        );
                        await tagProvider.clearTags();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("All tags have been deleted"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Statistics Section
            _buildSectionHeader("STATISTICS", context),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // CHANGED: Black in dark mode, white in light mode
              color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Task>('tasks').listenable(),
                builder: (context, Box<Task> box, _) {
                  final tasks = box.values.toList();
                  final totalTasks = tasks.length;
                  final completedTasks = tasks
                      .where((task) => task.isCompleted)
                      .length;
                  final pendingTasks = totalTasks - completedTasks;
                  final completionRate = totalTasks > 0
                      ? (completedTasks / totalTasks) * 100
                      : 0;

                  return Column(
                    children: [
                      _buildStatTile(
                        icon: Icons.list_alt,
                        title: "Total Tasks",
                        value: "$totalTasks",
                        isDarkMode: isDarkMode,
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                      ),
                      _buildStatTile(
                        icon: Icons.check_circle,
                        title: "Completed Tasks",
                        value: "$completedTasks",
                        color: Colors.green,
                        isDarkMode: isDarkMode,
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                      ),
                      _buildStatTile(
                        icon: Icons.pending_actions,
                        title: "Pending Tasks",
                        value: "$pendingTasks",
                        color: Colors.orange,
                        isDarkMode: isDarkMode,
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                      ),
                      _buildStatTile(
                        icon: Icons.analytics,
                        title: "Completion Rate",
                        value: "${completionRate.toStringAsFixed(1)}%",
                        color: _getCompletionRateColor(
                          completionRate.toDouble(),
                        ),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  );
                },
              ),
            ),

            // App Information Section
            _buildSectionHeader("APP INFORMATION", context),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // CHANGED: Black in dark mode, white in light mode
              color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: AppTheme.primaryCyan),
                    title: Text(
                      "Developer Info",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeveloperScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: AppTheme.primaryCyan),
                    title: Text(
                      "About App",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "ZenDo",
                        applicationVersion: "1.0.0",
                        applicationIcon: const Icon(
                          Icons.checklist,
                          size: 48,
                          color: AppTheme.primaryCyan,
                        ),
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            "A simple and smart todo app to help you organize your tasks efficiently. "
                            "Stay productive and manage your daily tasks with ease!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip,
                      color: AppTheme.primaryCyan,
                    ),
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Privacy Policy"),
                          content: const SingleChildScrollView(
                            child: Text(
                              "ZenDo values your privacy. We don't collect any personal data. "
                              "All your tasks and data are stored locally on your device.\n\n"
                              "• No data collection\n"
                              "• No third-party sharing\n"
                              "• Your data stays on your device\n\n"
                              "For any questions or concerns, please contact us at adnan02802@gmail.com",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "ZenDo v1.0.0",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white70 : Colors.black54,
          letterSpacing: 1.2,
        ),
      )
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required String value,
    Color color = Colors.black,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getCompletionRateColor(double rate) {
    if (rate >= 75) return Colors.green;
    if (rate >= 50) return Colors.orange;
    if (rate >= 25) return Colors.amber;
    return Colors.red;
  }
}