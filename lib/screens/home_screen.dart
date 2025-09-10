import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ZenDo/models/task.dart';
import 'package:ZenDo/screens/settings_screen.dart';
import 'package:ZenDo/providers/tag_provider.dart';
import 'add_task_screen.dart';
import 'package:ZenDo/models/user.dart';
import 'package:ZenDo/theme/app_theme.dart';
import 'package:ZenDo/utils/responsive.dart';
import 'package:ZenDo/services/notification_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<User>('user');
    final user = userBox.get('current_user');
    final box = Hive.box<Task>('tasks');

    return Container(
      decoration: AppTheme.gradientBoxDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: user != null
              ? Text(
                  user.welcomeMessage,
                  style: TextStyle(fontSize: Responsive.textSize(18, context)),
                )
              : Text(
                  "ZenDo",
                  style: TextStyle(fontSize: Responsive.textSize(18, context)),
                ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: Icon(
                Icons.settings,
                size: Responsive.textSize(24, context),
              ),
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<Task> box, _) {
            final tasks = box.values.toList();
            if (tasks.isEmpty) {
              return Center(
                child: Text(
                  "No Tasks yet",
                  style: TextStyle(
                    fontSize: Responsive.textSize(18, context),
                    color: Colors.white,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.key.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width(5, context),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: Responsive.textSize(24, context),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        final isDarkModeDialog =
                            Theme.of(context).brightness == Brightness.dark;
                        return Theme(
                          data: Theme.of(context).copyWith(
                            dialogTheme: DialogThemeData(
                              backgroundColor: isDarkModeDialog
                                  ? Colors.grey[900]
                                  : Colors.white,
                              titleTextStyle: TextStyle(
                                color: isDarkModeDialog
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: Responsive.textSize(20, context),
                                fontWeight: FontWeight.bold,
                              ),
                              contentTextStyle: TextStyle(
                                color: isDarkModeDialog
                                    ? Colors.white70
                                    : Colors.black87,
                                fontSize: Responsive.textSize(16, context),
                              ),
                            ),
                          ),
                          child: AlertDialog(
                            title: Text(
                              "Confirm Delete",
                              style: TextStyle(
                                color: isDarkModeDialog
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            content: Text(
                              "Are you sure you want to delete '${task.title}'?",
                              style: TextStyle(
                                color: isDarkModeDialog
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: isDarkModeDialog
                                        ? Colors.white70
                                        : Colors.blue,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  "Delete",
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
                  },
                  onDismissed: (direction) async {
                    await NotificationService.cancelNotification(task.id);

                    box.deleteAt(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Deleted ${task.title}")),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: Responsive.width(2, context),
                      vertical: Responsive.height(0.5, context),
                    ),
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: Responsive.textSize(16, context),
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description.isNotEmpty)
                            Text(
                              task.description,
                              style: TextStyle(
                                fontSize: Responsive.textSize(14, context),
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          SizedBox(height: Responsive.height(0.5, context)),
                          Text(
                            "${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: Responsive.textSize(12, context),
                              color: Colors.grey[600],
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (task.category.isNotEmpty &&
                              task.category != 'General')
                            Container(
                              margin: EdgeInsets.only(
                                top: Responsive.height(0.5, context),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.width(2, context),
                                vertical: Responsive.height(0.3, context),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(
                                  Responsive.width(3, context),
                                ),
                              ),
                              child: Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: Responsive.textSize(10, context),
                                  color: Colors.blue[700],
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) {
                              final updatedTask = Task(
                                id: task.id,
                                title: task.title,
                                description: task.description,
                                dueDate: task.dueDate,
                                hasAlarm: task.hasAlarm,
                                alarmTime: task.alarmTime,
                                category: task.category,
                                isCompleted: value ?? false,
                              );
                              box.put(task.id, updatedTask);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: Responsive.textSize(20, context),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddTaskScreen(editTask: task),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final tagProvider = Provider.of<TagProvider>(
              context,
              listen: false,
            );
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: tagProvider,
                  child: const AddTaskScreen(),
                ),
              ),
            );
          },
          child: Icon(Icons.add, size: Responsive.textSize(24, context)),
        ),
      ),
    );
  }
}
