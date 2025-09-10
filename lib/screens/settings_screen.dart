import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ZenDo/providers/theme_provider.dart';
import 'package:ZenDo/providers/tag_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ZenDo/models/task.dart';
import 'package:ZenDo/theme/app_theme.dart';
import 'developer_screen.dart';
import 'profile_screen.dart';
import 'package:ZenDo/utils/responsive.dart';
import 'package:ZenDo/services/notification_service.dart';

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
          title: Text(
            "Settings",
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.textSize(18, context),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
            size: Responsive.textSize(24, context),
          ),
        ),
        body: ListView(
          children: [
            // Profile Section
            _buildSectionHeader("YOUR PROFILE", context, isDarkMode),
            Card(
              margin: EdgeInsets.symmetric(
                horizontal: Responsive.width(4, context),
                vertical: Responsive.height(1, context),
              ),
              color: isDarkMode
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.width(3, context),
                ),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.person,
                  color: AppTheme.primaryCyan,
                  size: Responsive.textSize(24, context),
                ),
                title: Text(
                  "Your Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: Responsive.textSize(16, context),
                  ),
                ),
                subtitle: Text(
                  "Update your personal information",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: Responsive.textSize(14, context),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: Responsive.textSize(16, context),
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
            _buildSectionHeader("APPEARANCE", context, isDarkMode),
            Card(
              margin: EdgeInsets.symmetric(
                horizontal: Responsive.width(4, context),
                vertical: Responsive.height(1, context),
              ),
              color: isDarkMode
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.width(3, context),
                ),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.dark_mode,
                  color: AppTheme.primaryCyan,
                  size: Responsive.textSize(24, context),
                ),
                title: Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: Responsive.textSize(16, context),
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
            _buildSectionHeader("DATA MANAGEMENT", context, isDarkMode),
            Card(
              margin: EdgeInsets.symmetric(
                horizontal: Responsive.width(4, context),
                vertical: Responsive.height(1, context),
              ),
              color: isDarkMode
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.width(3, context),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.delete_sweep,
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                      size: Responsive.textSize(24, context),
                    ),
                    title: Text(
                      "Clear All Tasks",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: Responsive.textSize(16, context),
                      ),
                    ),
                    subtitle: Text(
                      "Permanently delete all tasks",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: Responsive.textSize(14, context),
                      ),
                    ),
                    trailing: Icon(
                      Icons.warning,
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                      size: Responsive.textSize(24, context),
                    ),
                    onTap: () =>
                        _showClearTasksConfirmation(context, isDarkMode),
                  ),
                  Divider(
                    height: 1,
                    indent: Responsive.width(4, context),
                    endIndent: Responsive.width(4, context),
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.label_off,
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                      size: Responsive.textSize(24, context),
                    ),
                    title: Text(
                      "Clear All Tags",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: Responsive.textSize(16, context),
                      ),
                    ),
                    subtitle: Text(
                      "Permanently delete all tags",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: Responsive.textSize(14, context),
                      ),
                    ),
                    trailing: Icon(
                      Icons.warning,
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                      size: Responsive.textSize(24, context),
                    ),
                    onTap: () =>
                        _showClearTagsConfirmation(context, isDarkMode),
                  ),
                ],
              ),
            ),

            // Statistics Section
            _buildSectionHeader("STATISTICS", context, isDarkMode),
            Card(
              margin: EdgeInsets.symmetric(
                horizontal: Responsive.width(4, context),
                vertical: Responsive.height(1, context),
              ),
              color: isDarkMode
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.width(3, context),
                ),
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
                        context: context,
                      ),
                      Divider(
                        height: 1,
                        indent: Responsive.width(4, context),
                        endIndent: Responsive.width(4, context),
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                      ),
                      _buildStatTile(
                        icon: Icons.check_circle,
                        title: "Completed Tasks",
                        value: "$completedTasks",
                        color: Colors.green,
                        isDarkMode: isDarkMode,
                        context: context,
                      ),
                      Divider(
                        height: 1,
                        indent: Responsive.width(4, context),
                        endIndent: Responsive.width(4, context),
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                      ),
                      _buildStatTile(
                        icon: Icons.pending_actions,
                        title: "Pending Tasks",
                        value: "$pendingTasks",
                        color: Colors.orange,
                        isDarkMode: isDarkMode,
                        context: context,
                      ),
                      Divider(
                        height: 1,
                        indent: Responsive.width(4, context),
                        endIndent: Responsive.width(4, context),
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
                        context: context,
                      ),
                    ],
                  );
                },
              ),
            ),

            // App Information Section
            _buildSectionHeader("APP INFORMATION", context, isDarkMode),
            Card(
              margin: EdgeInsets.symmetric(
                horizontal: Responsive.width(4, context),
                vertical: Responsive.height(1, context),
              ),
              color: isDarkMode
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.width(3, context),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: AppTheme.primaryCyan,
                      size: Responsive.textSize(24, context),
                    ),
                    title: Text(
                      "Developer Info",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: Responsive.textSize(16, context),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: Responsive.textSize(16, context),
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
                    indent: Responsive.width(4, context),
                    endIndent: Responsive.width(4, context),
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info,
                      color: AppTheme.primaryCyan,
                      size: Responsive.textSize(24, context),
                    ),
                    title: Text(
                      "About App",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: Responsive.textSize(16, context),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: Responsive.textSize(16, context),
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                    onTap: () {
                      _showAboutDialog(context, isDarkMode);
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: Responsive.width(4, context),
                    endIndent: Responsive.width(4, context),
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip,
                      color: AppTheme.primaryCyan,
                      size: Responsive.textSize(24, context),
                    ),
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: Responsive.textSize(16, context),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: Responsive.textSize(16, context),
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                    onTap: () {
                      _showPrivacyPolicyDialog(context, isDarkMode);
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(Responsive.width(4, context)),
              child: Text(
                "ZenDo 1.1.0",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.textSize(12, context),
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearTasksConfirmation(
    BuildContext context,
    bool isDarkMode,
  ) async {
    final confirmed = await showDialog<bool>(
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
        child: AlertDialog(
          title: Text(
            "Clear All Tasks",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: Text(
            "Are you sure you want to delete all tasks? This action cannot be undone.",
            style: TextStyle(fontSize: Responsive.textSize(16, context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.blue,
                  fontSize: Responsive.textSize(16, context),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Delete All",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: Responsive.textSize(16, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final taskBox = Hive.box<Task>('tasks');

      await NotificationService.cancelAllNotifications();

      await taskBox.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "All tasks have been deleted",
            style: TextStyle(fontSize: Responsive.textSize(14, context)),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showClearTagsConfirmation(
    BuildContext context,
    bool isDarkMode,
  ) async {
    final confirmed = await showDialog<bool>(
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
        child: AlertDialog(
          title: Text(
            "Clear All Tags",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: Text(
            "Are you sure you want to delete all tags? This action cannot be undone.",
            style: TextStyle(fontSize: Responsive.textSize(16, context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.blue,
                  fontSize: Responsive.textSize(16, context),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Delete All",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: Responsive.textSize(16, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      await tagProvider.clearTags();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "All tags have been deleted",
            style: TextStyle(fontSize: Responsive.textSize(14, context)),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAboutDialog(BuildContext context, bool isDarkMode) {
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
              fontSize: Responsive.textSize(14, context),
            ),
          ),
        ),
        child: AlertDialog(
          title: Text(
            "About ZenDo",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Icon(
                  Icons.checklist,
                  size: Responsive.textSize(48, context),
                  color: AppTheme.primaryCyan,
                ),
                SizedBox(height: Responsive.height(2, context)),
                Text(
                  "A simple and smart todo app to help you organize your tasks efficiently. "
                  "Stay productive and manage your daily tasks with ease!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: Responsive.textSize(14, context)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(fontSize: Responsive.textSize(16, context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isDarkMode) {
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
              fontSize: Responsive.textSize(14, context),
            ),
          ),
        ),
        child: AlertDialog(
          title: Text(
            "Privacy Policy",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: SingleChildScrollView(
            child: Text(
              "ZenDo values your privacy. We don't collect any personal data. "
              "All your tasks and data are stored locally on your device.\n\n"
              "• No data collection\n"
              "• No third-party sharing\n"
              "• Your data stays on your device\n\n"
              "For any questions or concerns, please contact us at adnan02802@gmail.com",
              style: TextStyle(fontSize: Responsive.textSize(14, context)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(fontSize: Responsive.textSize(16, context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    BuildContext context,
    bool isDarkMode,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.width(6, context),
        Responsive.height(2.5, context),
        Responsive.width(6, context),
        Responsive.height(1, context),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: Responsive.textSize(12, context),
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white70 : Colors.black54,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required String value,
    Color color = Colors.black,
    required bool isDarkMode,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: Responsive.textSize(24, context)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: Responsive.textSize(14, context),
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: Responsive.textSize(16, context),
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
