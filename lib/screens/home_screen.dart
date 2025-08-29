import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ZenDo/models/task.dart';
import 'package:ZenDo/screens/settings_screen.dart';
import 'package:ZenDo/providers/tag_provider.dart';
import 'add_task_screen.dart';
import 'package:ZenDo/models/user.dart';
import 'package:ZenDo/theme/app_theme.dart';

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
          title: user != null ? Text(user.welcomeMessage) : const Text("ZenDo"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<Task> box, _) {
            final tasks = box.values.toList();
            if (tasks.isEmpty) {
              return const Center(
                child: Text(
                  "No Tasks yet",
                  style: TextStyle(fontSize: 18, color: Colors.white),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: Text(
                            "Are you sure you want to delete '${task.title}'?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    box.deleteAt(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Deleted ${task.title}")),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
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
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            "${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (task.category.isNotEmpty &&
                              task.category != 'General')
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: 10,
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
                            icon: const Icon(Icons.edit, size: 20),
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
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
