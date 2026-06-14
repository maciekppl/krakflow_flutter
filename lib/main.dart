import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'models/task.dart';
import 'services/task_local_database.dart';
import 'services/task_sync_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox("tasks");

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String allFilter = 'wszystkie';
  static const String todoFilter = 'do zrobienia';
  static const String doneFilter = 'wykonane';

  String selectedFilter = allFilter;
  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    return TaskLocalDatabase.getTasks();
  }

  void _reloadTasksFromLocal() {
    tasksFuture = Future.value(TaskLocalDatabase.getTasks());
  }

  Future<void> _addTask(Task task) async {
    await TaskLocalDatabase.addTask(task);

    if (!mounted) {
      return;
    }

    setState(_reloadTasksFromLocal);
  }

  Future<void> _updateTask(Task task) async {
    await TaskLocalDatabase.updateTask(task);

    if (!mounted) {
      return;
    }

    setState(_reloadTasksFromLocal);
  }

  Future<void> _deleteTask(Task task) async {
    await TaskLocalDatabase.deleteTask(task.id);

    if (!mounted) {
      return;
    }

    setState(_reloadTasksFromLocal);
  }

  Future<void> _deleteAllTasks() async {
    await TaskLocalDatabase.deleteAllTasks();

    if (!mounted) {
      return;
    }

    setState(_reloadTasksFromLocal);
    _showSnackBar('Usunieto wszystkie zadania');
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (selectedFilter == doneFilter) {
      return tasks.where((task) => task.done).toList();
    }

    if (selectedFilter == todoFilter) {
      return tasks.where((task) => !task.done).toList();
    }

    return tasks;
  }

  Widget _buildFilterButton(String label, String filter) {
    final isSelected = selectedFilter == filter;

    return TextButton(
      onPressed: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.blue : Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KrakFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Potwierdzenie'),
                    content: const Text(
                      'Czy na pewno chcesz usunac wszystkie zadania?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Anuluj'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _deleteAllTasks();
                        },
                        child: const Text('Usun'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                _buildFilterButton('Wszystkie', allFilter),
                _buildFilterButton('Do zrobienia', todoFilter),
                _buildFilterButton('Wykonane', doneFilter),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Dzisiejsze zadania',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Blad: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('Brak danych'));
                  }

                  final tasks = snapshot.data!;
                  final doneCount = tasks.where((task) => task.done).length;
                  final filteredTasks = _filterTasks(tasks);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Masz dzis ${tasks.length} zadan'),
                      Text('Ukonczone $doneCount zadan'),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];

                            return Dismissible(
                              key: ValueKey(task.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) async {
                                await _deleteTask(task);
                                _showSnackBar('Usunieto: ${task.title}');
                              },
                              child: TaskCard(
                                title: task.title,
                                subtitle:
                                    'termin: ${task.deadline} | priorytet: ${task.priority}',
                                done: task.done,
                                onChanged: (value) async {
                                  final isDone = value ?? false;
                                  final wasDone = task.done;

                                  final updatedTask = task.copyWith(
                                    done: isDone,
                                  );

                                  await _updateTask(updatedTask);

                                  if (!wasDone && isDone) {
                                    await NotificationService.showTaskDoneNotification(
                                      task.title,
                                    );
                                  }
                                },
                                onTap: () async {
                                  final updatedTask =
                                      await Navigator.push<Task>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditTaskScreen(task: task),
                                        ),
                                      );

                                  if (updatedTask != null) {
                                    await _updateTask(updatedTask);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push<Task>(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );

          if (newTask != null) {
            await _addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: done, onChanged: onChanged),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: done ? Colors.grey : Colors.black),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: titleController.text.trim(),
      deadline: deadlineController.text.trim(),
      priority: priorityController.text.trim(),
      done: false,
    );

    Navigator.pop(context, newTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowe zadanie')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tytul zadania',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: 'Termin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: 'Priorytet',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _saveTask, child: const Text('Zapisz')),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController titleController = TextEditingController(
    text: widget.task.title,
  );
  late final TextEditingController deadlineController = TextEditingController(
    text: widget.task.deadline,
  );
  late final TextEditingController priorityController = TextEditingController(
    text: widget.task.priority,
  );

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final updatedTask = widget.task.copyWith(
      title: titleController.text.trim(),
      deadline: deadlineController.text.trim(),
      priority: priorityController.text.trim(),
    );

    Navigator.pop(context, updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edytuj zadanie')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tytul zadania',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: 'Termin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: 'Priorytet',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Zapisz zmiany'),
            ),
          ],
        ),
      ),
    );
  }
}
